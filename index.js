const express = require("express");
const app = express();
const bodyParser = require("body-parser");
const cors = require("cors")

const select = require("./pg/select")
const insert = require("./pg/insert")

app.use(cors())
app.use(bodyParser.urlencoded({extended: false}));
app.use(bodyParser.json());

app.get("/select", async (req, res) => {
    res.statusCode = 200;
    let dados = await select()
    console.log('retorno select', dados)
    res.json(dados);
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