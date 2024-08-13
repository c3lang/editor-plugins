import { Trace } from "vscode-jsonrpc";
import { workspace } from "vscode";
import { LanguageClient } from "vscode-languageclient";
import { join } from "path";
import { platform } from "os";

let client = null;
const config = workspace.getConfiguration("c3.lsp");

module.exports = {
  activate: activate,
  deactivate: deactivate
}

export function activate(context) {
  const enabled = config.get("enable");
  if (!enabled) {
    return;
  }

  let executablePath = config.get("path");

  if (executablePath == "") {
    switch (platform()) {
      case "win32": {
        executablePath = join(context.extensionPath, "c3-lsp.exe");
        break;
      }
      case "darwin": {
        executablePath = join(context.extensionPath, "c3-lsp");
        break;
      }
      case "linux": {
        executablePath = join(context.extensionPath, "c3-lsp");
        break;
      }
    }
  }

  let args = [];
  if (config.get("sendCrashReports")) {
    args.push("--send-crash-reports");
  }
  if (config.get("log.path") != "") {
    args.push("--log-path " + config.get("log.path"));
  }
  if (config.get("version") != "") {
    args.push("--lang-version " + config.get("version"));
  }
  const serverOptions = {
    run: {
      command: executablePath,
      args: args,
    },
    debug: {
      command: executablePath,
      args: args,
      options: { execArgv: ["--nolazy", "--inspect=6009"] },
    },
  };

  const clientOptions = {
    documentSelector: [{ scheme: "file", language: "c3" }],
    synchronize: {
      fileEvents: workspace.createFileSystemWatcher("**/*.c3"),
    },
  };

  client = new LanguageClient("C3LSP", serverOptions, clientOptions);
  if (config.get("debug")) {
    client.setTrace(Trace.Verbose);
  }
  client.start();
}
export function deactivate() {
  return client.stop();
  
}
