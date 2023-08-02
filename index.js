const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors")

const select = require("./pg/select")
const insert = require("./pg/insert")
const deletar = require("./pg/delete")

app.use(cors())
app.use(bodyParser.urlencoded({extended: false}));
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


app.get("/delete", async (req, res) => {
    res.statusCode = 200;
    let dados = await deletar()
    if (dados==='OK'){
        res.send('Tudo foi apagado na tabela TESTE01!!!');
    }
});


app.post("/insert", async (req, res) => { 
    var {texto} = req.body;
    console.log(texto)
    await insert(texto)
    res.sendStatus(200);
})

app.listen(3000,() => {
    console.log("API RODANDO! (3000)");
});