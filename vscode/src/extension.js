const { Trace } = require('vscode-jsonrpc');
const { window, workspace, commands, ExtensionContext, Uri } = require('vscode');
const { LanguageClient } = require('vscode-languageclient');
const path = require('path');
const os = require('os');

let client = null;
const config = workspace.getConfiguration('c3lspclient.lsp');

module.exports = {
  activate: function (context) {
    const enabled = config.get('enable');
    if (!enabled) {
        return;
    }

    let executablePath = config.get('path');
    
    /*if (executablePath == "") {
        switch(os.platform()) {
          // case "win32": binary_path = "c3-lsp-win"
          case "darwin": executablePath = path.join(context.extensionPath, "c3-lsp")
          case "linux": executablePath = path.join(context.extensionPath, "c3-lsp")
        }
    }*/
    
    let args = [];
    if (config.get('sendCrashReports')) {
      args.push('--send-crash-reports');
    }
    const serverOptions = {
      run: {
        command: executablePath,
        args: args,
      },
      debug: {
        command: executablePath,
        args: args,
        options: { execArgv: ['--nolazy', '--inspect=6009'] }
      }
    }

    const clientOptions = {
      documentSelector: [{ scheme: 'file', language:'c3'}],
      synchronize: {
        fileEvents: workspace.createFileSystemWatcher('**/*.c3')
      }
    }

    client = new LanguageClient(
      'C3LSP',
      serverOptions,
      clientOptions
    );
    client.setTrace(Trace.Verbose);
    client.start();
  },

  deactivate: function () {
    const enabled = config.get('enable');
    if (enabled) {
        return client.stop();
    }
  }
}
