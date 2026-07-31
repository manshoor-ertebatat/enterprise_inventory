module.exports = {
  plugins: [
    require('postcss-discard-duplicates'),
    require('cssnano')({
      preset: ['default', {
        mergeRules: true,
        discardDuplicates: true
      }]
    })
  ]
}
