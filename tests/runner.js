let path = require("path");
let fs = require("fs");
let cp = require("child_process");

let parser = path.join(process.cwd(), "./lib/rescript.exe");

let refmt = path.join(process.cwd(), "lib", "refmt.exe");

function parseBinaryReason(filename) {
  let intf = isInterface(filename);
  let args = ["--print", "binary"];

  if (intf) {
    args.push("--interface");
    args.push("true");
  }

  args.push(filename);

  return cp.spawnSync(refmt, args).stdout;
}

function classifyLang(filename) {
  if (filename.length > 3) {
    let suffix = filename.substring(filename.length - 3);
    if (suffix === ".re" || suffix === "rei") {
      return "reason";
    } else if (suffix === ".ml" || suffix === "mli") {
      return "ocaml";
    }
  }
  return "rescript";
}

function isInterface(filename) {
  if (filename.length === 0) {
    return false;
  } else {
    return filename[filename.length - 1] === "i";
  }
}

function parseFile(filename, recover, env) {
  let args = ["-print", "ml"];
  if (recover) args.push("-recover");
  args.push(filename);
  return env ? cp.spawnSync(parser, args, { env }) : cp.spawnSync(parser, args);
}

function parseOcamlFileToNapkin(filename) {
  let { stdout } = cp.spawnSync(parser, [
    "-parse",
    "ml",
    "-print",
    "res",
    filename,
  ]);
  return stdout.toString();
}

function parseOcamlFileToSexp(filename) {
  return cp
    .spawnSync(parser, ["-parse", "ml", "-print", "sexp", filename])
    .stdout.toString();
}

function parseReasonFileToSexp(filename) {
  let reasonBinary = parseBinaryReason(filename);

  let intf = isInterface(filename);

  let args = ["-parse", "reasonBinary", "-print", "sexp"];
  if (intf) {
    args.push("-interface");
  }
  return cp
    .spawnSync(parser, args, {
      input: reasonBinary,
      encoding: null,
    })
    .stdout.toString();
}

function parseNapkinFileToSexp(filename) {
  let { stdout } = cp.spawnSync(parser, [
    "-parse",
    "res",
    "-print",
    "sexp",
    filename,
  ]);
  return stdout.toString();
}

function parseFileToSexp(filename) {
  let lang = classifyLang(filename);

  switch (lang) {
    case "reason":
      return parseReasonFileToSexp(filename);

    case "ocaml":
      return parseOcamlFileToSexp(filename);

    default:
      return parseNapkinFileToSexp(filename);
  }
}

function parseReasonFileToNapkin(filename, width = 100) {
  let intf = isInterface(filename);
  let reasonBinary = parseBinaryReason(filename);
  let args = ["-parse", "reasonBinary", "-print", "res", "-width", width.toString()];

  if (intf) {
    args.push("-interface");
  }

  return cp
    .spawnSync(parser, args, { input: reasonBinary })
    .stdout.toString("utf8");
}

function parseNapkinStdinToSexp(src, isInterface) {
  let args = ["-parse", "res", "-print", "sexp"];
  if (isInterface) {
    args.push("-interface");
  }
  return cp
    .spawnSync(parser, args, {
      input: src,
    })
    .stdout.toString("utf8");
}

function parseNapkinStdinToNapkin(src, isInterface, width = 100) {
  let args = ["-parse", "res", "-print", "res", "-width", width];
  if (isInterface) {
    args.push("-interface");
  }
  return cp
    .spawnSync(parser, args, {
      input: src,
    })
    .stdout.toString("utf8");
}

function printFile(filename) {
  let parserSrc;
  switch (classifyLang(filename)) {
    case "ocaml":
      parserSrc = "ml";
      break;

    case "reason":
      parserSrc = "re";
      return parseReasonFileToNapkin(filename, 80);
      break;

    case "rescript":
    default:
      parserSrc = "res";
      break;
  }

  let intf = isInterface(filename);

  let args = ["-parse", parserSrc, "-print", "res", "-width", "80"];

  if (intf) {
    args.push("-interface");
  }

  args.push(filename);

  return cp.spawnSync(parser, args).stdout.toString("utf8");
}

/* Parser error output format:
   /home/travis/build/IwanKaramazow/syntax/tests/parsing/errors/scanner/oldDerefOp.js 1:4-5

   test output contains the file's absolute path. Turn it relative to make it
   machine-independent
*/
let makeReproducibleFilename = (txt) => {
  return txt.replace(/(  Syntax error!\n  )(.+)( .+)\n/g, (match, intro, filepath, loc) => {
    return intro + path.relative(__dirname, filepath) + loc
  })
};

global.runPrinter = (dirname) => {
  fs.readdirSync(dirname).forEach((base) => {
    let filename = path.join(dirname, base);
    if (!fs.lstatSync(filename).isFile() || base === "render.spec.js") {
      return;
    }

    test(base, () => {
      let napkin = printFile(filename);
      expect(napkin).toMatchSnapshot();

      if (process.env.ROUNDTRIP_TEST) {
        let intf = isInterface(filename);
        let sexpAst = parseFileToSexp(filename);
        let napkin2 = parseNapkinStdinToNapkin(napkin, intf, 80);
        let napkinSexpAst = parseNapkinStdinToSexp(napkin, intf);
        expect(sexpAst).toEqual(napkinSexpAst);
        expect(napkin).toEqual(napkin2);
      }
    });
  });
};

global.runParser = (dirname, recover = false, showError = false, env) => {
  fs.readdirSync(dirname).forEach((base) => {
    let filename = path.join(dirname, base);
    if (!fs.lstatSync(filename).isFile() || base === "parse.spec.js") {
      return;
    }

    test(base, () => {
      let res = parseFile(filename, recover, env);
      let parsetree = res.stdout.toString();
      let output = "";
      if (showError) {
        output += `=====Parsetree==========================================\n`;
        output += `${parsetree}\n`;
        output += `=====Errors=============================================\n`;
        output += `${makeReproducibleFilename(res.stderr.toString())}\n`;
        output += `========================================================`;
      } else {
        output = parsetree;
      }

      expect(output).toMatchSnapshot();
    });
  });
};

global.idemPotency = (dirname) => {
  let describeFn = process.env.ROUNDTRIP_TEST ? describe : describe.skip;

  describeFn(dirname, () => {
    fs.readdirSync(dirname).forEach((base) => {
      let filename = path.join(dirname, base);
      if (!fs.lstatSync(filename).isFile() || base === "parse.spec.js") {
        return;
      }

      let lang = classifyLang(base);

      let parseToNapkin;

      switch (lang) {
        case "reason":
          parseToNapkin = parseReasonFileToNapkin;
          break;

        case "ocaml":
        default:
          parseToNapkin = parseOcamlFileToNapkin;
      }

      test(base, () => {
        let intf = isInterface(filename);
        let napkin = parseToNapkin(filename);
        let sexpAst = parseFileToSexp(filename);
        let napkinSexpAst = parseNapkinStdinToSexp(napkin, intf);
        let napkin2 = parseNapkinStdinToNapkin(napkin, intf);
        expect(sexpAst).toEqual(napkinSexpAst);
        expect(napkin).toEqual(napkin2);
      });
    });
  });
};
