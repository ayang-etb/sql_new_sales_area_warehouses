
// prettier.config.js
module.exports = {
  plugins: ["prettier-plugin-sql"],
  // pick your dialect
  language: "postgresql", // or 'mysql' | 'mariadb' | 'sqlite' | 'sql' | 'bigquery' | 'spark'
  printWidth: 100,
  sqlFormatter: {
    keywordCase: "upper",
    indentStyle: "standard",
    linesBetweenQueries: 2
  }
};
