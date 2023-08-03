const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors")

const select = require("./pg/select")
const insert = require("./pg/insert")
const deletar = require("./pg/delete")

app.use(cors())
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.get("/select", async (req, res) => {
    res.statusCode = 200;
    let dados = await select()
    console.log('retorno select', dados)
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
                    ,COALESCE(sell.qtdneg,0) as qtdneg
                FROM produto AS pro LEFT JOIN selloutitem  AS sell ON (sell.idproduto=pro.id)
                WHERE  sell.idsellout IS NULL OR sell.idsellout=${idsellout};`
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
    var { texto } = req.body;
    console.log(texto)
    await insert(texto)
    res.sendStatus(200);
})

app.listen(3000, () => {
    console.log("API RODANDO! (3000)");
});