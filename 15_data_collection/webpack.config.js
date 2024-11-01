import path from 'path';

export default {
  entry: './src/index.ts',
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
    ],
  },
  resolve: {
    extensions: ['.ts', '.js'],
  },
  output: {
    filename: 'bundle.js',
    path: path.resolve('D:\\develop\\code\\java\\BlockChainLearn\\15_data_collection', 'dist'), // 确保这里的 __dirname 是正确的
  },
  mode: 'development',
};
