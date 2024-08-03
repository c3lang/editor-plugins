use zed_extension_api::{self as zed, Result};

struct C3Extension;

impl zed::Extension for C3Extension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let c3lsp_cmd = worktree.which("c3-lsp");
        let path = c3lsp_cmd.ok_or_else(|| "c3-lsp must be in your path".to_string())?;

        Ok(zed::Command {
            command: path,
            args: vec![],
            env: Default::default(),
        })
    }
}

zed::register_extension!(C3Extension);
