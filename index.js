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
    //Esta consulta usa dados da query para buscar na tabela, exemplo http://localhost:3000/consulta?operacao=produto
    let consulta = req.query
    res.statusCode = 200;
    let dados = await select(consulta.operacao)
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
                FROM sellout as sell 
                LEFT JOIN promoter pro ON (pro.id = sell.idpromoter) 
                LEFT JOIN loja ON (sell.idloja = loja.id)
                WHERE pro.id=${idpromoter};`
    let dados = await select(query, true)
    res.json(dados);
});

app.get("/loadSelloutitem", async (req, res) => {
    //Esta consulta usa dados da query para buscar na tabela, exemplo http://localhost:3000/consulta?operacao=produto
    let idsellout = req.query.idsellout
    res.statusCode = 200;
    let query = `SELECT 
                    pro.id as idproduto
                    ,pro.descrprod as descrprod
                    ,COALESCE((SELECT qtdneg FROM selloutitem WHERE idproduto=pro.id AND idsellout=${idsellout}),0) as qtdneg
                FROM produto AS pro ;`
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
    await insert(query).then(_=>{ 
        res.sendStatus(200)
    }) //Falta tratar erros do BD
        .catch(err => {
            res.send('err')
            console.log('erro')
        })
})


app.post("/insertSelloutItem", async (req, res) => {
    var ins = req.body;
    console.log(ins)
    let query = `INSERT INTO selloutitem (idsellout, idproduto,  qtdneg)
                VALUES ($1, $2, $3) ON CONFLICT (idsellout, idproduto)
                DO UPDATE SET qtdneg = $3;`
    await insertArray(query, ins)
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

    var {usuario, senha} = req.body;
    console.log('auth', usuario, senha)
    
    let query = `SELECT nome, senha FROM promoter WHERE nome='${usuario}'`

    let DB = {}
    let dados = await select(query, true)
    DB.users = dados

    if(usuario != undefined){

        //console.log(DB, DB.users[0].nome, usuario)
        var user = DB.users.find(u => u.nome == usuario);
        if(user != undefined){
            if(user.senha == senha){
                jwt.sign({id: user.id, usuario: user.usuario},JWTSecret,{expiresIn:'48h'},(err, token) => {
                    if(err){
                        res.status(400);
                        res.json({err:"Falha interna"});
                    }else{
                        res.status(200);
                        res.json({token: token});
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


app.listen(3000, () => {
    console.log("API RODANDO! (3000)");
});