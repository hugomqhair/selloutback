const { Client } = require('pg');

// Configuração da conexão com o PostgreSQL
const config = {
  user: 'postgres',
  host: 'localhost',
  database: 'teste',
  password: 'postgres',
  port: 5432, // Porta padrão do PostgreSQL
};




// Função para gravar dados no banco de dados
module.exports = 
async function deletarTudo(dados) {
    // Crie uma instância do cliente PostgreSQL
    const client = new Client(config);
  
    try {
      // Conecte-se ao banco de dados
      await client.connect();
  
  
      // Consulta SQL para inserir os dados na tabela
      const query = 'DELETE FROM teste01';
  
      // Executa a consulta passando os dados como parâmetros
      const resultado = await client.query(query);
  
      // Exibe o resultado
      console.log('Todos dados foram apagados na tabela TESTE01');
      return 'OK'
    } catch (err) {
      console.error('Erro ao gravar dados:', err);
    } finally {
      // Fecha a conexão com o banco de dados
      await client.end();
    }
  }
  
  // Chama a função para gravar os dados
  //deletarTudo();