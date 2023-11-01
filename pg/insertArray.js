const { Pool } = require('pg');

// Configuração da conexão com o PostgreSQL
const config = {
    user: 'postgres',
    host: 'localhost',
    database: 'sellout',
    password: 'postgres',
    port: 5432, // Porta padrão do PostgreSQL
  };


module.exports=
async function insertRecords(query, records) {
  const pool = new Pool(config);
  const client = await pool.connect();
  let resultado = 0
  try {
    // Cria a conexão com o banco de dados

    // Inicia uma transação
    await client.query('BEGIN');

    // Cria o comando SQL de inserção utilizando o array de registros
    const insertQuery =  query
    
    let resp
    // Executa o comando SQL para cada registro do array
    // console.log(records)
    // console.log(query)

    for (const record of records) {
      //console.log(query, Object.values(record))
      resp = await client.query(insertQuery, Object.values(record));
      resultado += resp.rowCount
    }

    // record.idsellout,
    // record.idproduto,
    // record.qtdneg,

    // record.id,
    // record.descr,
    // record.grupo,




    // Finaliza a transação com commit
    let resp2 = await client.query('COMMIT');
    console.log('Registros inseridos com sucesso!');
    //console.log(resp2)
  } catch (err) {
    // Caso ocorra algum erro, desfaz a transação
    await client.query('ROLLBACK');
    console.error('Erro ao inserir registros:', err);
  } finally {
    // Fecha a conexão com o banco de dados
    pool.end();
  }
}

// Chama a função para inserir os registros
//insertRecords();
