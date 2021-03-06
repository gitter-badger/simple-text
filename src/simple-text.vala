using Gtk;

public class SimpleText : Gtk.Application {
	private GLib.Settings settings;
	private PreferencesDialog preferences_dialog;
	private MainWindow window;

	private const GLib.ActionEntry[] app_entries = {
		{ "prefs", show_prefs_cb, null, null, null },
        { "about", about_cb, null, null, null },
        { "quit", quit_cb, null, null, null },
    };

	public SimpleText() {
		Object(application_id: "badwolfie.simple-text.app",
			flags: ApplicationFlags.HANDLES_OPEN);
	}

	protected override void startup() {
		base.startup();

		var conf_dir = File.new_for_path(
			Environment.get_home_dir() + "/.simple-text");

		var saved_workspace = File.new_for_path(
			Environment.get_home_dir() + "/.simple-text/saved-workspace");

		try {
			if (!conf_dir.query_exists())
				conf_dir.make_directory();
				
			if (!saved_workspace.query_exists())
				saved_workspace.create(FileCreateFlags.PRIVATE);
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}
		
		var editor = new TextEditor();
		settings = new GLib.Settings("com.github.badwolfie.simple-text");
		
		editor.show_line_numbers = settings.get_boolean("show-line-numbers");
		editor.show_right_margin = settings.get_boolean("show-right-margin");
		editor.right_margin_at = settings.get_int("right-margin-at");
		editor.use_text_wrap = settings.get_boolean("use-text-wrap");
		editor.highlight_current_line = 
			settings.get_boolean("highlight-current-line");
		editor.highlight_brackets = settings.get_boolean("highlight-brackets");
		editor.show_grid_pattern = settings.get_boolean("show-grid-pattern");
		editor.tab_width = settings.get_int("tab-width");
		editor.insert_spaces = settings.get_boolean("insert-spaces");
		editor.auto_indent = settings.get_boolean("auto-indent");
		editor.use_default_typo = settings.get_boolean("use-default-typo");
		editor.editor_font = settings.get_string("editor-font");
		editor.color_scheme = settings.get_string("color-scheme");
		editor.prefer_dark = settings.get_boolean("prefer-dark");
		
		add_action_entries(app_entries,this);
		window = new MainWindow(this,editor);		

		var builder = new Gtk.Builder();
		try {
			builder.add_from_resource(
				"/com/github/badwolfie/simple-text/menu.ui");
		} catch (Error e) {
			error("Error loading menu UI: %s",e.message);
		}
		
		var menu = builder.get_object("appmenu") as MenuModel;
		set_app_menu(menu);

		const string[] accels_re_open = {"<control><shift>T",null};
		set_accels_for_action("win.re_open",accels_re_open);

		const string[] accels_save_as = {"<control><shift>S",null};
		set_accels_for_action("win.save_as",accels_save_as);

		const string[] accels_set_syntax = {"<control><shift>P",null};
		set_accels_for_action("win.set_syntax",accels_set_syntax);
		
		const string[] accels_show_terminal = {"<control><shift>C",null};
		set_accels_for_action("win.toggle_terminal",accels_show_terminal);

		const string[] accels_next_tab = {"<control>Tab",null};
		set_accels_for_action("win.next_tab",accels_next_tab);

		const string[] accels_prev_tab = {"<control><shift>Tab",null};
		set_accels_for_action("win.prev_tab",accels_prev_tab);

		const string[] accels_close = {"<control>W",null};
		set_accels_for_action("win.close_tab",accels_close);

		const string[] accels_search = {"<control>F",null};
		set_accels_for_action("win.search_mode",accels_search);

		const string[] accels_quit = {"<control>Q",null};
		set_accels_for_action("win.quit_window",accels_quit);
		
		Posix.system("clear");
	}

	protected override void activate() {
		base.activate();
		
		window.arg_files = null;		
		window.present();
	}
	
	protected override void open(File[] files, string hint) {
		base.open(files, hint);
		
		window.arg_files = files;
		window.present();
	}

	protected override void shutdown() {
		base.shutdown();
		
		var editor = window.editor;

		settings.set_boolean("show-line-numbers", editor.show_line_numbers);
		settings.set_boolean("show-right-margin", editor.show_right_margin);
		settings.set_int("right-margin-at", editor.right_margin_at);
		settings.set_boolean("use-text-wrap", editor.use_text_wrap);
		settings.set_boolean("highlight-current-line", 
							 editor.highlight_current_line);
		settings.set_boolean("highlight-brackets", editor.highlight_brackets);
		settings.set_boolean("show-grid-pattern", editor.show_grid_pattern);
		settings.set_int("tab-width", editor.tab_width);
		settings.set_boolean("insert-spaces", editor.insert_spaces);
		settings.set_boolean("auto-indent", editor.auto_indent);
		settings.set_boolean("use-default-typo", editor.use_default_typo);
		if (editor.use_default_typo)
			settings.reset("editor-font");
		else
			settings.set_string("editor-font", editor.editor_font);
		settings.set_string("color-scheme", editor.color_scheme);
		settings.set_boolean("prefer-dark", editor.prefer_dark);
	}
	
	private void show_prefs_cb() {
		if (preferences_dialog == null) 
			preferences_dialog = new PreferencesDialog(window,window.editor);
		preferences_dialog.present();
	}

	private void about_cb() {
		string[] authors = { "Ian Hernández <ihernandezs@openmailbox.org>" };

		string[] documenters = { "Ian Hernández" };

		const string[] contributors = { 
			"Carlos López <clopezr_1205@openmailbox.org>" 
		};
		
		var translator_credits = _("translator-credits");

		string license = 
		"""Simple Text is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 of the License, or
(at your option) any later version.

Simple Text is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Simple Text. If not, see <http://www.gnu.org/licenses/>.""";

		var about_dialog = new AboutDialog();
		about_dialog.set_transient_for(window);

        about_dialog.program_name = ("Simple Text");
		about_dialog.title = _("About") + " Simple Text";
		about_dialog.copyright = ("Copyright \xc2\xa9 2015 Ian Hernández");
		about_dialog.comments = 
			_("A not so simple text and code editor written in Vala");
		about_dialog.website = ("https://github.com/BadWolfie/simple-text");
		about_dialog.website_label = _("Web page");
		about_dialog.license = license;
		about_dialog.logo_icon_name = ("text-editor");
		about_dialog.documenters = documenters;
		about_dialog.authors = authors;
		about_dialog.translator_credits = translator_credits;
		about_dialog.version = ("0.9.8");

		about_dialog.add_credit_section(_("Contributors"),contributors);

		about_dialog.run();
		about_dialog.destroy();
	}

	private void quit_cb() {
		window.destroy();
	}

	public static int main(string[] args) {
		Intl.setlocale(LocaleCategory.ALL, "");
        Intl.bindtextdomain(Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset(Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain(Config.GETTEXT_PACKAGE);
        
		Gtk.Window.set_default_icon_name ("text-editor");
		var app = new SimpleText();

		return app.run(args);
	}
}
