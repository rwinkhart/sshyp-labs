#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <stddef.h>
#include <gtk/gtk.h>

GtkWidget *label_selected; GtkListBox *list_box;  // TODO remove necessity for global widgets
char entries[1024][1024]; int entry_array_count = 0;

void str_remove(char *str, const char *sub) {
    char *p, *q, *r;
    if (*sub && (q = r = strstr(str, sub)) != 0) {
        size_t len = strlen(sub);
        while ((r = strstr(p = r + len, sub)) != 0) {
            while (p < r)
                *q++ = *p++;
        }
        while ((*q++ = *p++) != '\0')
            continue;
    }
}

void gen_entry_array(char *path, size_t size, const char *path_orig) {
    DIR *dir;
    struct dirent *entry;
    size_t len = strlen(path);

    if (!(dir = opendir(path))) {
        return; }

    while ((entry = readdir(dir)) != 0) {
        char *name = entry->d_name;
        if (entry->d_type == DT_DIR) {
            if (!strcmp(name, ".") || !strcmp(name, "..")) {
                continue; }
            path[len] = '/';
            strcpy(path + len + 1, name);
            gen_entry_array(path, size, path_orig);
            path[len] = '\0';
        } else {
            char path_filtered[1024];
            strcpy(path_filtered, path);
            str_remove(path_filtered, path_orig);
            size_t name_len = strlen(name);
            name[name_len-4] = 0;
            char sshyp_path[1024]; strcpy(sshyp_path, path_filtered); strcat(sshyp_path, "/"); strcat(sshyp_path, name);
            strcpy(entries[entry_array_count], sshyp_path);
            entry_array_count++;
        }
    }
    closedir(dir);
}

void password_convert(GtkEntryBuffer *buffer) {
    const char *password = gtk_entry_buffer_get_text(buffer);
    char *sub1 = "gpg --pinentry-mode loopback --batch --passphrase-fd 0 --armor -qd --output /dev/null ~/.config/sshyp/lock.gpg <<< '", *sub2 = "'", command[1024];
    strcpy(command, sub1); strcat(command, password); strcat(command, sub2);
    system(command);
}

void gpg_lock() {
    system("gpgconf --reload gpg-agent");
}

void password_prompt(GtkWindow *window) {
    GtkWidget *dialog, *dialog_header, *box_header;  // main window and header bar
    GtkWidget *button_unlock, *button_cancel, *button_lock;  // header bar buttons
    GtkWidget *content_area, *password_entry;  // content area and widgets

    dialog = gtk_dialog_new();
        password_entry = gtk_entry_new();
            gtk_entry_set_visibility(GTK_ENTRY(password_entry), FALSE);
            gtk_entry_set_placeholder_text(GTK_ENTRY(password_entry), "passphrase");
        dialog_header = gtk_header_bar_new();
            gtk_header_bar_set_show_title_buttons(GTK_HEADER_BAR(dialog_header), FALSE);
            box_header = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
                gtk_widget_set_halign(box_header, GTK_ALIGN_CENTER);
                button_unlock = gtk_button_new_with_label("unlock");
                button_cancel = gtk_button_new_with_label("cancel");
                button_lock = gtk_button_new_from_icon_name("changes-prevent");
                    gtk_widget_set_size_request(button_lock, 20, -1);
                gtk_box_append(GTK_BOX(box_header), button_unlock);
                gtk_box_append(GTK_BOX(box_header), button_cancel);
                gtk_box_append(GTK_BOX(box_header), button_lock);
            gtk_header_bar_set_title_widget(GTK_HEADER_BAR(dialog_header), box_header);
        gtk_window_set_title(GTK_WINDOW(dialog), "");
        gtk_window_set_transient_for(GTK_WINDOW(dialog), GTK_WINDOW(window));
        gtk_window_set_modal(GTK_WINDOW(dialog), TRUE);
        gtk_window_set_default_size(GTK_WINDOW(dialog), 50, 50);

        // add password entry to dialog content area
        content_area = gtk_dialog_get_content_area(GTK_DIALOG(dialog));
        gtk_box_append(GTK_BOX(content_area), password_entry);

        gtk_window_set_titlebar(GTK_WINDOW(dialog), dialog_header);
        gtk_widget_show(dialog);

        // button actions
        g_signal_connect_swapped(button_unlock, "clicked", G_CALLBACK(password_convert), gtk_entry_get_buffer(GTK_ENTRY(password_entry)));
        g_signal_connect_swapped(button_unlock, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect_swapped(button_cancel, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect(button_lock, "clicked", G_CALLBACK(gpg_lock), 0);
        g_signal_connect_swapped(button_lock, "clicked", G_CALLBACK(gtk_window_close), dialog);
}

void copy_edit_field_prompt(GtkWindow *window) {
    GtkWidget *dialog, *dialog_header;  // main window and header bar
    GtkWidget *button_cancel;  // header bar buttons
    GtkWidget *content_area, *button_pwd, *button_usr, *button_url, *button_nte, *button_mfa;  // content area and widgets

    dialog = gtk_dialog_new();
        dialog_header = gtk_header_bar_new();
            gtk_header_bar_set_show_title_buttons(GTK_HEADER_BAR(dialog_header), FALSE);
            button_cancel = gtk_button_new_with_label("cancel");
            gtk_header_bar_set_title_widget(GTK_HEADER_BAR(dialog_header), button_cancel);
        gtk_window_set_title(GTK_WINDOW(dialog), "");
        gtk_window_set_transient_for(GTK_WINDOW(dialog), GTK_WINDOW(window));
        gtk_window_set_modal(GTK_WINDOW(dialog), TRUE);
        gtk_window_set_default_size(GTK_WINDOW(dialog), 50, 50);

        // add options to dialog content area
        content_area = gtk_dialog_get_content_area(GTK_DIALOG(dialog));
            button_pwd = gtk_button_new_with_label("password");
            button_usr = gtk_button_new_with_label("username");
            button_url = gtk_button_new_with_label("url");
            button_nte = gtk_button_new_with_label("note");
            button_mfa = gtk_button_new_with_label("mfa");
            gtk_box_append(GTK_BOX(content_area), button_pwd);
            gtk_box_append(GTK_BOX(content_area), button_usr);
            gtk_box_append(GTK_BOX(content_area), button_url);
            gtk_box_append(GTK_BOX(content_area), button_nte);
            gtk_box_append(GTK_BOX(content_area), button_mfa);

        gtk_window_set_titlebar(GTK_WINDOW(dialog), dialog_header);
        gtk_widget_show(dialog);

        // button actions
        g_signal_connect_swapped(button_cancel, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect_swapped(button_pwd, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect_swapped(button_usr, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect_swapped(button_url, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect_swapped(button_nte, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect_swapped(button_mfa, "clicked", G_CALLBACK(gtk_window_close), dialog);
}

void set_selection_label(GtkWidget *button, gpointer *label) {
    const char *button_label = gtk_button_get_label(GTK_BUTTON(button));
    gtk_label_set_text(GTK_LABEL(label), button_label);
}

void entry_list_gen() {
    GtkWidget *entry_button;

    GtkWidget *iter = gtk_widget_get_first_child ((GtkWidget *) list_box);
    while (iter != 0) {
        GtkWidget *next = gtk_widget_get_next_sibling (iter);
        gtk_list_box_remove (list_box, iter);
        iter = next;
    }

    char path[1024]; char *user_home = getenv("HOME"); strcpy(path, user_home); strcat(path, "/.local/share/sshyp");
    char path_orig[1024]; strcpy(path_orig, path); strcat(path_orig, "/");
    gen_entry_array(path, sizeof path, path_orig);
    strcpy(entries[entry_array_count], "\0");

    for (int i = 0; strcmp(entries[i], "\0") != 0; i++) {
        entry_button = gtk_button_new_with_label(entries[i]);
        gtk_label_set_xalign(GTK_LABEL(gtk_button_get_child(GTK_BUTTON(entry_button))), GTK_JUSTIFY_LEFT);
        gtk_button_set_has_frame(GTK_BUTTON(entry_button), FALSE);
        g_signal_connect(entry_button, "clicked", G_CALLBACK(set_selection_label), (gpointer *)label_selected);
        gtk_list_box_append(list_box, gtk_separator_new(GTK_ORIENTATION_HORIZONTAL));
        gtk_list_box_append(list_box, entry_button);
    }
}

void sshyp_sync() {
    system("sshyp sync");
    entry_array_count = 0;
    entry_list_gen();
}

static void activate(GtkApplication* app) {
    GtkWidget *window, *header_bar;  // main window and header bar
    GtkWidget *button_sync, *button_unlock;  // header bar buttons
    GtkWidget *stack, *stack_switcher; GtkStackPage *page_info;  // stack widgets
    GtkWidget *box_info, *sshyp_logo, *label_home1;  // info page widgets
    GtkWidget *box_browse_page, *box_browse_controls;  // browse page boxes
    GtkWidget *button_shear, *button_read, *button_edit, *button_copy;  // browse buttons
    GtkWidget *scrollable;  // scrollable entry list container

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "");
    gtk_window_set_default_size(GTK_WINDOW(window), 360, 720);

    header_bar = gtk_header_bar_new();
        gtk_header_bar_set_show_title_buttons(GTK_HEADER_BAR(header_bar), FALSE);

    // !!start main stack stuff!!

    // create the stack
    stack = gtk_stack_new();
        gtk_stack_set_transition_type(GTK_STACK(stack), GTK_STACK_TRANSITION_TYPE_SLIDE_LEFT_RIGHT);

    // attach the stack to the main window
    gtk_window_set_child(GTK_WINDOW(window), stack);

    // browse
    button_shear = gtk_button_new_from_icon_name("edit-delete");
        gtk_widget_set_hexpand(button_shear, FALSE);
        gtk_widget_set_size_request(button_shear, 50, -1);
    button_read = gtk_button_new_from_icon_name("mail-read");
        gtk_widget_set_hexpand(button_read, TRUE);
    button_edit = gtk_button_new_from_icon_name("document-edit");
        gtk_widget_set_hexpand(button_edit, TRUE);
        g_signal_connect_swapped(button_edit, "clicked", G_CALLBACK(copy_edit_field_prompt), window);
    button_copy = gtk_button_new_from_icon_name("edit-copy");
        g_signal_connect_swapped(button_copy, "clicked", G_CALLBACK(copy_edit_field_prompt), window);
        gtk_widget_set_hexpand(button_copy, TRUE);
    box_browse_page = gtk_box_new(GTK_ORIENTATION_VERTICAL, 0);
        label_selected = gtk_label_new("no entry selected");
        gtk_widget_set_hexpand(label_selected, TRUE);
        gtk_widget_set_halign(label_selected, GTK_ALIGN_CENTER);
        box_browse_controls = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
            gtk_widget_set_valign(box_browse_controls, GTK_ALIGN_START);
            gtk_widget_set_size_request(box_browse_controls, -1, 50);
            gtk_box_append(GTK_BOX(box_browse_controls), button_shear);
            gtk_box_append(GTK_BOX(box_browse_controls), button_read);
            gtk_box_append(GTK_BOX(box_browse_controls), button_edit);
            gtk_box_append(GTK_BOX(box_browse_controls), button_copy);
        gtk_box_append(GTK_BOX(box_browse_page), label_selected);
        gtk_box_append(GTK_BOX(box_browse_page), box_browse_controls);

        // !!start scrollable list!!
        scrollable = gtk_scrolled_window_new();
            list_box = (GtkListBox *) gtk_list_box_new();
                gtk_widget_set_vexpand(GTK_WIDGET(list_box), TRUE);

                entry_list_gen();

            gtk_scrolled_window_set_child(GTK_SCROLLED_WINDOW(scrollable), GTK_WIDGET(list_box));
        // !!end scrollable list!!

        gtk_box_append(GTK_BOX(box_browse_page), GTK_WIDGET(scrollable));

    // info
    box_info = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10);
        sshyp_logo = gtk_image_new_from_file("PLACEHOLDER");
            gtk_image_set_pixel_size(GTK_IMAGE(sshyp_logo), 300);
        label_home1 = gtk_label_new("password pasture\nexperimental gui client for sshyp");
            gtk_label_set_justify(GTK_LABEL(label_home1), GTK_JUSTIFY_CENTER);
            gtk_label_set_markup(GTK_LABEL(label_home1), "<span size='large'><b>password pasture</b></span>\n<span size='small'>experimental gui client for sshyp</span>");
        gtk_box_append(GTK_BOX(box_info), sshyp_logo);
        gtk_box_append(GTK_BOX(box_info), label_home1);

    stack_switcher = gtk_stack_switcher_new();
        page_info = gtk_stack_add_titled(GTK_STACK(stack), box_info, "info", "info");
            gtk_stack_page_set_icon_name(GTK_STACK_PAGE(page_info), "help-about");
        gtk_stack_add_titled(GTK_STACK(stack), box_browse_page, "browse", "browse");
        gtk_stack_switcher_set_stack(GTK_STACK_SWITCHER(stack_switcher), GTK_STACK(stack));
    gtk_header_bar_pack_start(GTK_HEADER_BAR(header_bar), stack_switcher);

    // !!end main stack stuff!!

    // header bar buttons
    button_sync = gtk_button_new_from_icon_name("view-refresh");
        g_signal_connect(button_sync, "clicked", G_CALLBACK(sshyp_sync), 0);
    gtk_header_bar_pack_end(GTK_HEADER_BAR(header_bar), button_sync);

    button_unlock = gtk_button_new_from_icon_name("changes-allow");
        g_signal_connect_swapped(button_unlock, "clicked", G_CALLBACK(password_prompt), window);
    gtk_header_bar_pack_end(GTK_HEADER_BAR(header_bar), button_unlock);

    //GtkWidget *button_debug = gtk_button_new_from_icon_name("applications-science");
        //g_signal_connect(button_debug, "clicked", G_CALLBACK(0), 0);
    //gtk_header_bar_pack_end(GTK_HEADER_BAR(header_bar), button_debug);

    gtk_window_set_titlebar(GTK_WINDOW(window), header_bar);
    gtk_widget_show(window);
}

int main(int    argc,
      char **argv) {
    GtkApplication *app = gtk_application_new("org.rwinkhart.sshyp", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), 0);
    int status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);
    return status;
}
