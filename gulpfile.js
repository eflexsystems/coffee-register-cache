var gulp = require('gulp');
var coffee = require('gulp-coffee2');

gulp.task('build', function(){
  gulp.src('./src/index.coffee')
    .pipe(coffee())
    .pipe(gulp.dest('./'));
});

gulp.task('default', ['build']);
