const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors")
const jwt = require("jsonwebtoken");

const select = require("./pg/select")
const insert = require("./pg/insert")
const insertArray = require("./pg/insertArray")
const deletar = require("./pg/delete")

const JWTSecret = "@Matrix122221"

app.use(cors())
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());



app.get("/select", auth, async (req, res) => {
    let consulta = req.body
    console.log(consulta)
    res.statusCode = 200;
    let dados = await select(consulta.operacao)
    //console.log('retorno select', consulta.operacao)
    res.json(dados);
});

app.get("/consulta", async (req, res) => {
    //console.log(req.query)
    //Esta consulta usa dados da query para buscar na tabela, exemplo http://localhost:3000/consulta?operacao=produto
    let consulta = req.query
    let query 
    let isQuery
    if(consulta.operacao == 'loja'){
        query = `SELECT id, nome, idpromoter FROM loja WHERE idpromoter=${req.query.user} ORDER BY nome`
        isQuery = true
    } else if (consulta.operacao == 'resultadomensal'){
        query = `SELECT TO_CHAR(dtmov,'MM/YYYY') AS mes
                        ,idpromoter
                        ,count(id) as dias
                        ,SUM(qtdneg) AS qtdneg
                    FROM sellout
                    WHERE idpromoter=${req.query.user}
                    GROUP BY TO_CHAR(dtmov,'MM/YYYY'), idpromoter
                    ORDER BY TO_CHAR(dtmov,'MM/YYYY') DESC;
                `
        isQuery = true
    } else if (consulta.operacao == 'resultadoAdmin'){
        query = `SELECT 
                        (SELECT nome FROM promoter WHERE id=idpromoter) as promoter
                        ,SUM(qtdneg) AS qtdneg
                        ,COUNT(dtmov) AS dias
                    FROM sellout
                    WHERE dtmov BETWEEN  date_trunc('month', current_date) AND (date_trunc('month', current_date) + interval '1 month - 1 day')
                    GROUP BY idpromoter
                    ORDER BY 2;`
        isQuery = true
    }else {
        query = consulta.operacao 
        isQuery = false
    }
    let dados = await select(query, isQuery)
    res.statusCode = 200;
    res.json(dados);
});


app.get("/obterSellouts", async (req, res) => {
    //Esta consulta usa dados da query para buscar na tabela, exemplo http://localhost:3000/consulta?operacao=produto
    let idpromoter = req.query.idpromoter
    res.statusCode = 200;
    let query = `SELECT 
                    sell.id
                    ,sell.dtmov
                    ,TO_CHAR(dtmov,'DD/MM/YYYY') AS fmt_dtmov
                    ,loja.nome as loja
                    ,pro.nome as vend
                    ,sell.qtdneg 
                FROM sellout as sell 
                LEFT JOIN promoter pro ON (pro.id = sell.idpromoter) 
                LEFT JOIN loja ON (sell.idloja = loja.id)
                WHERE pro.id=${idpromoter} ORDER BY dtmov DESC LIMIT 7;`
    let dados = await select(query, true)
    res.json(dados);
});

app.get("/loadSelloutitem", async (req, res) => {
    //Esta consulta usa dados da query para buscar na tabela, exemplo http://localhost:3000/consulta?operacao=produto
    let idsellout = req.query.idsellout
    res.statusCode = 200;
    let query = `SELECT 
                    pro.id as idproduto
                    ,fnc_limpa_descrprod(pro.id) as descrprod
                    ,COALESCE((SELECT qtdneg FROM selloutitem WHERE idproduto=pro.id AND idsellout=${idsellout}),0) as qtdneg
                    ,pro.grupo
                    ,COALESCE((SELECT semestoque FROM produtolojaestoque WHERE idproduto=pro.id AND idloja=(SELECT idloja FROM sellout WHERE id=${idsellout})),false) AS semestoque
                    ,COALESCE((SELECT semcadastro FROM produtolojaestoque WHERE idproduto=pro.id AND idloja=(SELECT idloja FROM sellout WHERE id=${idsellout})),false) AS semcadastro
                    ,DENSE_RANK() OVER (ORDER BY grupo) AS idgrupo
                FROM produto AS pro  ORDER BY grupo, descrprod;`
    let dados = await select(query, true)
    res.json(dados);
});


app.get("/delete", async (req, res) => {
    res.statusCode = 200;
    let dados = await deletar()
    if (dados === 'OK') {
        res.send('Tudo foi apagado na tabela TESTE01!!!');
    }
});


app.post("/insert", async (req, res) => {
    var ins = req.body;
    console.log(ins)
    let query = `INSERT INTO TESTE01 (TEXTO, VALOR) VALUES ('${ins.texto}', ${ins.valor});`
    await insert(query)
    res.sendStatus(200);
})

app.post("/insertSellout", async (req, res) => {
    var ins = req.body;
    console.log(ins)
    let query = `INSERT INTO sellout (idpromoter, idloja, dtmov) VALUES (${ins.idpromoter}, ${ins.idloja}, '${ins.dtmov}');`
    let dados = await insert(query)
    //console.log(dados)
    if(dados===1){
        res.status(200).send('Dia cadastrado com sucesso!')
    } else {
        res.status(401).send(dados)
    }
    // res.send('Testando!!!')
    // res.sendStatus('Testando', 200)
})


app.post("/insertSelloutItem", async (req, res) => {
    console.log(req.body)
    var ins = req.body;
    ins = ins.map(body => ({idproduto:body.idproduto, idsellout:body.idsellout, qtdneg:body.qtdneg, semcadastro:body.semcadastro, semestoque:body.semestoque}))
    //console.log('body', ins)
    //let {idproduto, idsellout, qtdneg} = Object.keys(ins[0])
    let query = `INSERT INTO selloutitem (idproduto, idsellout,qtdneg, semcadastro, semestoque)
                VALUES ($1, $2, $3, $4, $5) ON CONFLICT (idproduto, idsellout)
                DO UPDATE SET qtdneg = $3, semcadastro=$4, semestoque=$5 ;`
    await insertArray(query, ins)
    .then(_ => {
        res.sendStatus(200)
    }).catch(err => res.sendStatus(500))
})


//Login
function auth(req, res, next){
    const authToken = req.headers['authorization'];

    if(authToken != undefined){

        const bearer = authToken.split(' ');
        var token = bearer[1];

        jwt.verify(token,JWTSecret,(err, data) => {
            if(err){
                res.status(401);
                res.json({err:"Token inválido!"});
            }else{

                req.token = token;
                req.loggedUser = {id: data.id,usuario: data.email};
                req.empresa = "Guia do programador";                
                next();
            }
        });
    }else{
        res.status(401);
        res.json({err:"Token inválido!"});
    } 
}

app.post("/auth",async (req, res) => {

    var {usuario, senha} = req.body
    usuario = usuario.toUpperCase();
    
    console.log('auth', usuario, senha)
    
    let query = `SELECT id, nome, senha FROM promoter WHERE UPPER(nome)=UPPER('${usuario}')`

    let DB = {}
    let dados = await select(query, true)
    DB.users = dados

    if(usuario != undefined){

        //console.log(DB, DB.users[0].nome, usuario)
        var user = DB.users.find(u => u.nome == usuario);
        if(user != undefined){
            if(user.senha == senha){
                jwt.sign({id:user.id, usuario: user.nome},JWTSecret,{expiresIn:'48h'},(err, token) => {
                    if(err){
                        res.status(400);
                        res.json({err:"Falha interna"});
                    }else{
                        res.status(200);
                        //console.log('Token:', {token: token, id:user.id, usuario: user.nome})
                        res.json({token: token, id:user.id, usuario: user.nome});
                    }
                })
            }else{
                res.status(401);
                res.json({err: "Credenciais inválidas!"});
            }
        }else{
            res.status(404);
            res.json({err: "O usuário enviado não existe na base de dados!"});
        }

    }else{
        res.status(400);
        res.send({err: "O usuário enviado é inválido"});
    }
});





//Insere Promoter
app.post("/promoter", async (req, res) => {
    var ins = req.body;
    console.log(ins)
    let query = `INSERT INTO promoter (id, nome, senha,idger) VALUES (${ins.id},UPPER('${ins.nome}'), '${ins.senha}', ${ins.idger})
                ON CONFLICT(id) DO UPDATE SET nome=UPPER('${ins.nome}'), senha='${ins.senha}',idger=${ins.idger};`
    await insert(query).then(_=>{ 
        res.sendStatus(200)
    }) //Falta tratar erros do BD
        .catch(err => {
            console.log('erro insert Promoter', err)
            res.send('err', err)
        })
})

//Insere PromoterLoja
app.post("/loja", async (req, res) => {
    var ins = req.body;
    ins = ins.map(arr => ({id:arr.id, idpromoter:arr.idpromoter, nome:arr.nome}))
    console.log(typeof ins, ins)
    let query = `INSERT INTO loja (id, idpromoter, nome ) VALUES ($1, $2, UPPER($3))
                ON CONFLICT(id) DO UPDATE SET idpromoter=$2, nome=UPPER($3)`
    await insertArray(query, ins).then(_=>{ 
        res.sendStatus(200)
    }) //Falta tratar erros do BD
        .catch(err => {
            console.log('erro insert Promoter', err)
            res.send('err', err)
        })
})

//Insere Produto
app.post("/produto", async (req, res) => {
    var ins = req.body;
    //console.log(typeof ins)
    let query = `INSERT INTO produto (descrprod, grupo, id) VALUES (UPPER($1), UPPER($2), $3)
                ON CONFLICT(id) DO UPDATE SET descrprod=UPPER($1), grupo=UPPER($2);`
    await insertArray(query, ins).then(_=>{ 
        res.sendStatus(200)
    }) //Falta tratar erros do BD
        .catch(err => {
            console.log('erro insert Promoter', err)
            res.send('err', err)
        })
})


//apenas testes
app.post("/teste", async (req, res) => {
    var ins = req.body;
    console.log(ins)
    if(ins){
        res.status(200)
        res.send({info: "Legal Chegou"})
    } else {
        res.status(400)
        res.send({info: "Eroo"})
    }
})

app.listen(3000, () => {
    console.log("API RODANDO! (3000)");
});