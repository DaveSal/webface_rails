const express  = require('express')
var bodyParser = require('body-parser');
const fs       = require('fs');
const app      = express();
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.set('view engine', 'pug')

// This is the main page where all tests are loaded and mocha is plugged in
app.get("/", function (req, res) {
  var file = req.query.file;
  if(file == "" || file == null)
    file = "webface.test.js";
  else if(file.startsWith("test"))
    file = file.replace("test", "");

  fs.readFile(`mocha.html`, 'utf8', function(err, contents) {
    res.render(__dirname + "/mocha.pug", { file: file });
  });
})

// These ones are needed in case you need to test an ajax_request
app.post("/ajax_test", function (req, res, next) {
  res.type("application/json");
  res.end(JSON.stringify(req.body));
});
app.get("/ajax_test", function (req, res, next) {
  res.type("application/json");
  res.end(JSON.stringify(req.query));
});


// This one is in charge of loading additional files required for the tests, such as: js, css, html, images.
app.get(/.+/, function (req, res) {
  var fn = req.path.substring(1);
  if(fn.endsWith("/")) fn = fn.slice(0, -1);

  var fn_splitted = fn.split("/");
  var fn_last_part = fn_splitted[fn_splitted.length - 1]


  if(/^[^.]+$/.test(fn_last_part))
    fn = fn + "/index.html";

  fn = __dirname + "/" + fn;

  if(fs.existsSync(fn)) {
    fs.readFile(fn, 'utf8', function(err, contents) {
      if(fn.endsWith(".js"))
        res.type("application/javascript");
      else if(fn.endsWith(".svg")) {
        res.type("image/svg+xml");
      }
      else if(fn.endsWith(".css"))
        res.type("text/css");
      else
        res.type("text/html");
      res.end(contents);
    });
  }
  else {
    res.status(404).send("Not found");
  }


})

app.listen(8080, () => console.log('Test server for Webface.js running on port 8080.'))
