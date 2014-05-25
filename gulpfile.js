var gulp = require('gulp');
var coffee = require('gulp-coffee');
var exec = require('child_process').exec;

gulp.task('coffee', function(done) {
  gulp.src('./src/*.coffee')
    .pipe(coffee({bare: true, sourceMap: true}).on('error', console.log))
    .pipe(gulp.dest('./public/'))
  exec('cp ./src/*.coffee ./public', done);
});

gulp.task('clean', function(done) {
  exec('rm ./public/*', done);
});
