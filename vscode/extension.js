const { Trace } = require('vscode-jsonrpc');
const { window, workspace, commands, ExtensionContext, Uri } = require('vscode');
const { LanguageClient } = require('vscode-languageclient');

let client = null;
const config = workspace.getConfiguration('c3.lsp');

module.exports = {
  activate: function (context) {
    const enabled = config.get('enable');
    if (!enabled) {
        return;
    }
    const executablePath = config.get('path');

    const serverOptions = {
      run: {
        command: executablePath,
      },
      debug: {
        command: executablePath,
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
