let gulp    = require('gulp')
let pug     = require('gulp-pug')
let mcss    = require('gulp-mcss')
let sass    = require('gulp-sass')
let uglify  = require('gulp-uglify-es').default
let connect = require('gulp-connect')

gulp.task('styles', () => {
    gulp.src(['src/scss/main.scss'])
        .pipe(sass())
        .pipe(mcss())
        .pipe(gulp.dest('css'))
        .pipe(connect.reload())
})

gulp.task('fonts', () =>{
    gulp.src(['src/fonts/*'] )
        .pipe(gulp.dest('fonts'))
        .pipe(connect.reload())
})

gulp.task('images', () => {
    gulp.src(['src/images/*'])
        .pipe(gulp.dest('img'))
        .pipe(connect.reload())
})

gulp.task('pug', () =>{
    gulp.src('src/templates/*.pug')
        .pipe(pug())
        .pipe(gulp.dest(''))
        .pipe(connect.reload())
})

gulp.task('js', () => {
    gulp.src(['src/js/*.js'])
        .pipe(uglify())
        .pipe(gulp.dest('js'))
        .pipe(connect.reload())
})

// server
gulp.task('server', () => {
    connect.server({
        root: ['.'],
        // https: true,
        livereload: true,
        // port: 443,
        port: 8081,
    })
})

gulp.task('watch', () =>{
    gulp.watch(['src/scss/*'  ], ['styles'])
    gulp.watch(['src/images/*'  ], ['images'])
    gulp.watch(['src/*/*.pug'], ['pug'])
    gulp.watch(['src/js/*.js'], ['js'])
})

gulp.task('default',
    [
        'styles',
        'fonts',
        'images',
        'pug',
        'js',
        'server',
        'watch',
    ]
)
