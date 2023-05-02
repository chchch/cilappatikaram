const path = require('path');
module.exports = {
    entry: './index.js',
    target: 'web',
    output: {
        filename: 'mirador.js',
        path: path.resolve(__dirname, 'dist'),
    },
};
