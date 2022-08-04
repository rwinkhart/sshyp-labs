#include <gtk/gtk.h>
//#include <stdlib.h>



void password_convert(GtkEntryBuffer *buffer)
{
    const char *password = gtk_entry_buffer_get_text(buffer);
    char *com1 = "gpg --pinentry-mode loopback --batch --passphrase-fd 0 --armor -qd --output /dev/null ~/.config/sshyp/lock.gpg <<< '";
    char *com2 = "'";
    char dest[1000];
    strcpy(dest, com1);
    strcat(dest, password);
    strcat(dest, com2);
    system(dest);
}

void password_prompt(GtkWindow *window)
{
    GtkWidget *dialog;
    GtkWidget *password_entry;
    GtkWidget *box_header;
    GtkWidget *button_unlock, *button_cancel;
    GtkWidget *dialog_header;
    GtkWidget *content_area;

    dialog = gtk_dialog_new();

        password_entry = gtk_entry_new();
            gtk_entry_set_visibility(GTK_ENTRY(password_entry), FALSE);
            gtk_entry_set_placeholder_text(GTK_ENTRY(password_entry), "passphrase");
        dialog_header = gtk_header_bar_new();
            box_header = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
                gtk_widget_set_halign(box_header, GTK_ALIGN_CENTER);
                gtk_box_set_homogeneous(GTK_BOX(box_header), TRUE);
            gtk_header_bar_set_show_title_buttons(GTK_HEADER_BAR(dialog_header), FALSE);
            button_unlock = gtk_button_new_with_label("unlock");
            button_cancel = gtk_button_new_with_label("cancel");
            gtk_box_append(GTK_BOX(box_header), button_unlock);
            gtk_box_append(GTK_BOX(box_header), button_cancel);
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
        g_signal_connect_swapped(button_cancel, "clicked", G_CALLBACK(gtk_window_close), dialog);
        g_signal_connect_swapped(button_unlock, "clicked", G_CALLBACK(password_convert), gtk_entry_get_buffer(GTK_ENTRY(password_entry)));
        g_signal_connect_swapped(button_unlock, "clicked", G_CALLBACK(gtk_window_close), dialog);
}


void sshyp_sync()
{
    system("sshyp sync");
}

void gpg_lock()
{
    system("gpgconf --reload gpg-agent");
}

static void activate(GtkApplication* app)
{
    GtkWidget *window;
    GtkWidget *button_debug, *button_sync, *button_lock, *button_unlock, *button_shear, *button_read;
    GtkWidget *button_copy_pwd, *button_copy_usr, *button_copy_url, *button_copy_nte, *button_copy_mfa;
    GtkWidget *button_edit_pwd, *button_edit_usr, *button_edit_url, *button_edit_nte;
    GtkWidget *grid_main, *grid_browse;
    GtkWidget *box_pwd, *box_usr, *box_url, *box_nte, *box_mfa;
    GtkWidget *header_bar;
    GtkWidget *stack, *stack_browse;
    GtkWidget *stack_switcher, *stack_switcher_browse;
    GtkWidget *box_home, *sshyp_logo, *label_home1;

    window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "");
    gtk_window_set_default_size(GTK_WINDOW(window), 720, 1440);

    header_bar = gtk_header_bar_new();

    button_sync = gtk_button_new_from_icon_name("view-refresh");
    g_signal_connect(button_sync, "clicked", G_CALLBACK(sshyp_sync), NULL);
    gtk_header_bar_pack_end(GTK_HEADER_BAR(header_bar), button_sync);

    button_unlock = gtk_button_new_from_icon_name("changes-allow");
    g_signal_connect_swapped(button_unlock, "clicked", G_CALLBACK(password_prompt), window);
    gtk_header_bar_pack_end(GTK_HEADER_BAR(header_bar), button_unlock);

    button_lock = gtk_button_new_from_icon_name("changes-prevent");
    g_signal_connect(button_lock, "clicked", G_CALLBACK(gpg_lock), NULL);
    gtk_header_bar_pack_end(GTK_HEADER_BAR(header_bar), button_lock);

    button_debug = gtk_button_new_from_icon_name("applications-science");
    g_signal_connect(button_debug, "clicked", G_CALLBACK(NULL), NULL);
    gtk_header_bar_pack_end(GTK_HEADER_BAR(header_bar), button_debug);

    grid_main = gtk_grid_new();
    gtk_widget_set_halign(grid_main, GTK_ALIGN_CENTER);
    gtk_widget_set_valign(grid_main, GTK_ALIGN_START);
    gtk_window_set_child(GTK_WINDOW(window), grid_main);

    // start stack stuff
    stack = gtk_stack_new();
    gtk_stack_set_transition_type(GTK_STACK(stack), GTK_STACK_TRANSITION_TYPE_SLIDE_LEFT_RIGHT);
    gtk_grid_attach(GTK_GRID(grid_main), stack, 0, 0, 1, 1);

    // home
    box_home = gtk_box_new(GTK_ORIENTATION_VERTICAL, 10);
        sshyp_logo = gtk_image_new_from_file("PLACEHOLDER");
            gtk_image_set_pixel_size(GTK_IMAGE(sshyp_logo), 300);
        label_home1 = gtk_label_new("password pasture\nexperimental gui client for sshyp");
            gtk_label_set_justify(GTK_LABEL(label_home1), GTK_JUSTIFY_CENTER);
            gtk_label_set_markup(GTK_LABEL(label_home1), "<span size='large'><b>password pasture</b></span>\n<span size='small'>experimental gui client for sshyp</span>");
        gtk_box_append(GTK_BOX(box_home), sshyp_logo);
        gtk_box_append(GTK_BOX(box_home), label_home1);
    gtk_stack_add_titled(GTK_STACK(stack), box_home, "home", "home");

    // browse
        // resources
        button_shear = gtk_button_new_from_icon_name("edit-delete");
        button_read = gtk_button_new_from_icon_name("mail-read");
        stack_browse = gtk_stack_new();
            box_pwd = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
                gtk_box_set_homogeneous(GTK_BOX(box_pwd), TRUE);
                button_copy_pwd = gtk_button_new_from_icon_name("edit-copy");
                button_edit_pwd = gtk_button_new_from_icon_name("document-edit");
                gtk_box_append(GTK_BOX(box_pwd), button_copy_pwd);
                gtk_box_append(GTK_BOX(box_pwd), button_edit_pwd);
                gtk_stack_add_titled(GTK_STACK(stack_browse), box_pwd, "password", "password");
            box_usr = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
                gtk_box_set_homogeneous(GTK_BOX(box_usr), TRUE);
                button_copy_usr = gtk_button_new_from_icon_name("edit-copy");
                button_edit_usr = gtk_button_new_from_icon_name("document-edit");
                gtk_box_append(GTK_BOX(box_usr), button_copy_usr);
                gtk_box_append(GTK_BOX(box_usr), button_edit_usr);
                gtk_stack_add_titled(GTK_STACK(stack_browse), box_usr, "username", "username");
            box_url = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
                gtk_box_set_homogeneous(GTK_BOX(box_url), TRUE);
                button_copy_url = gtk_button_new_from_icon_name("edit-copy");
                button_edit_url = gtk_button_new_from_icon_name("document-edit");
                gtk_box_append(GTK_BOX(box_url), button_copy_url);
                gtk_box_append(GTK_BOX(box_url), button_edit_url);
                gtk_stack_add_titled(GTK_STACK(stack_browse), box_url, "url", "url");
            box_nte = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
                gtk_box_set_homogeneous(GTK_BOX(box_nte), TRUE);
                button_copy_nte = gtk_button_new_from_icon_name("edit-copy");
                button_edit_nte = gtk_button_new_from_icon_name("document-edit");
                gtk_box_append(GTK_BOX(box_nte), button_copy_nte);
                gtk_box_append(GTK_BOX(box_nte), button_edit_nte);
                gtk_stack_add_titled(GTK_STACK(stack_browse), box_nte, "note", "note");
            box_mfa = gtk_box_new(GTK_ORIENTATION_HORIZONTAL, 0);
                gtk_box_set_homogeneous(GTK_BOX(box_mfa), TRUE);
                button_copy_mfa = gtk_button_new_from_icon_name("edit-copy");
                gtk_box_append(GTK_BOX(box_mfa), button_copy_mfa);
                gtk_stack_add_titled(GTK_STACK(stack_browse), box_mfa, "mfa", "mfa");
    stack_switcher_browse = gtk_stack_switcher_new();
    gtk_stack_switcher_set_stack(GTK_STACK_SWITCHER(stack_switcher_browse), GTK_STACK(stack_browse));
    grid_browse = gtk_grid_new();
    gtk_widget_set_halign(grid_browse, GTK_ALIGN_START);
    gtk_widget_set_valign(grid_browse, GTK_ALIGN_START);
    gtk_grid_attach(GTK_GRID(grid_browse), button_shear, 0, 0, 1, 2);
    gtk_grid_attach(GTK_GRID(grid_browse), button_read, 1, 0, 1, 2);
    gtk_grid_attach(GTK_GRID(grid_browse), stack_switcher_browse, 2, 1, 1, 1);
    gtk_grid_attach(GTK_GRID(grid_browse), stack_browse, 2, 0, 1, 1);
    gtk_stack_add_titled(GTK_STACK(stack), grid_browse, "browse", "browse");

    stack_switcher = gtk_stack_switcher_new();
    gtk_stack_switcher_set_stack(GTK_STACK_SWITCHER(stack_switcher), GTK_STACK(stack));
    gtk_header_bar_pack_start(GTK_HEADER_BAR(header_bar), stack_switcher);
    // end stack stuff

    gtk_window_set_titlebar(GTK_WINDOW(window), header_bar);
    gtk_widget_show(window);
}

int main(int    argc,
      char **argv)
{
    GtkApplication *app;
    int status;

    app = gtk_application_new("org.rwinkhart.sshyp", G_APPLICATION_FLAGS_NONE);
    g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
    status = g_application_run(G_APPLICATION(app), argc, argv);
    g_object_unref(app);

    return status;
}
