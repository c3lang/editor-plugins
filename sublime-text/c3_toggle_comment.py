import sublime
import sublime_plugin

class C3ToggleCommentCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        for region in self.view.sel():
            if region.empty():
                # Toggle comment on the current line
                line = self.view.line(region)
                self.toggle_line_comment(edit, line)
            else:
                # Toggle comment on each line in the selected region
                self.toggle_region_comments(edit, region, edit)

    def toggle_line_comment(self, edit, line):
        text = self.view.substr(line)
        
        if text.startswith("//"):
            # Uncomment by removing // from the start of the line
            uncommented_text = text[2:]
            self.view.replace(edit, line, uncommented_text)
        else:
            # Comment by adding // at the start of the line
            commented_text = "//" + text
            self.view.replace(edit, line, commented_text)

    def toggle_region_comments(self, edit, region, view_edit):
        # Process each line in the selected region separately
        lines = self.view.split_by_newlines(region)
        all_commented = all(self.view.substr(line).startswith("//") for line in lines)

        # Collect the modified text for each line in sequence
        modified_text = []

        for line in lines:
            text = self.view.substr(line)

            if all_commented:
                # Uncomment each line by removing // only if it is at the start
                if text.startswith("//"):
                    uncommented_text = text[2:]
                    modified_text.append(uncommented_text)
                else:
                    modified_text.append(text)
            else:
                # Comment each line by adding // at the start
                commented_text = "//" + text
                modified_text.append(commented_text)

        # Join all modified lines into a single block of text
        new_content = "\n".join(modified_text)

        # Replace the entire region with the modified block of text
        self.view.replace(view_edit, region, new_content)
