# difficulty-estimator
Prototype for the encounter difficulty calculator page

CSCI 5200 (Software Systems Engineering) | Fall 2017

## Building

This is written in [Elm](http://elm-lang.org/) - you will need to have [Elm installed](https://guide.elm-lang.org/install.html) to compile the source into an HTML file.

The app has three main pieces:
- `index.html` - static page that loads compiled Javascript
- `diffcalc.elm` - all the page logic and contents
- `style.css` - CSS rules

To compile, run
`$ elm-make diffcalc.elm --output build/elm.js`

Then open `./index.html` to see the page.

## Architecture

Have a look at [The Elm Architecture](https://guide.elm-lang.org/architecture/) for how the data flow works.

## To-Do

- [ ] refactor actions to reduce duplication
- [x] change build to compile to js and use static html file
- [x] extract static CSS to separate file
- [ ] add calculations output
- [ ] add full calculation tables with show/hide option

