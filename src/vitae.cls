%% vitae.cls -- a LaTeX class for building resumes.
%% Content is stored by this class; look and feel come from vitaetheme<name>.sty.
%% Distributed under the MIT license (see LICENSE).

% --- Identification -------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass{vitae}{2026-11-24}{0.6.0}{Resume class}

% --- Options and base class -----------------------------------------------
% Defaults first, user options after: the last paper/size option wins.
\PassOptionsToClass { a4paper, 11pt } { article }
\DeclareOption* { \PassOptionsToClass { \CurrentOption } { article } }
\ProcessOptions \relax
\LoadClass { article }
% Identity, contacts, dates, templates and themes, shared with vitaeletter.
\RequirePackage { vitaecore }

% --- Messages -------------------------------------------------------------
\msg_new:nnn { vitae } { empty-list } { List~'#1'~is~empty~or~undefined. }
\msg_new:nnn { vitae } { unknown-style }
  { Entry~style~'#1'~has~no~template~'entry/#1';~the~default~is~used. }

% --- Sections -------------------------------------------------------------
% \section[*][<options>]{<title>} goes through the section template (no
% numbering). Option "icon" gives the template \field{icon}, hidden from
% readers and text extraction; an optional argument without "=" (a short
% title) is ignored.
\keys_define:nn { vitae / section }
  {
    icon .code:n =
      \tl_if_blank:nF {#1}
        { \tl_set:Nn \l__vitae_f_icon_tl { \actualtext { } {#1} } } ,
  }
\RenewDocumentCommand \section { s o m }
  {
    \group_begin:
      \skip_zero:N \parskip
      \tl_clear:N \l__vitae_f_icon_tl
      \IfValueT {#2}
        { \tl_if_in:nnT {#2} { = } { \keys_set:nn { vitae / section } {#2} } }
      \tl_set:Nn \l__vitae_f_title_tl {#3}
      \__vitae_template_use:n { section }
    \group_end:
  }

% --- Entries and items ----------------------------------------------------
% Structural groups (masthead, section, entry, item) run with \parskip = 0,
% so template lines keep their exact spacing whatever the setting; bodies
% are set with \__vitae_body_set:n (see vitaecore).
% Entry fields are set by keys; "date" sets start and end at once.
\tl_new:N \l__vitae_entry_style_tl
\keys_define:nn { vitae / entry }
  {
    title    .tl_set:N = \l__vitae_f_title_tl ,
    org      .tl_set:N = \l__vitae_f_org_tl ,
    location .tl_set:N = \l__vitae_f_location_tl ,
    start    .tl_set:N = \l__vitae_f_start_tl ,
    end      .tl_set:N = \l__vitae_f_end_tl ,
    date     .meta:n   = { start = {#1} , end = {#1} } ,
    % Layout for this entry: template "entry/<style>" ("full" = "entry").
    style    .tl_set:N = \l__vitae_entry_style_tl ,
    % Date settings for this entry only (the entry is a group).
    dateformat .meta:nn = { vitae / setup } { dateformat = {#1} } ,
    locale     .meta:nn = { vitae / setup } { locale = {#1} } ,
    datelocale .meta:nn = { vitae / setup } { datelocale = {#1} } ,
    durations  .meta:nn = { vitae / setup } { durations = {#1} } ,
    durations  .default:n = true ,
  }
% \cventry{<keys>}{<body>}: set fields, derive "dates", run the template.
\NewDocumentCommand \cventry { m +m }
  {
    \group_begin:
      \skip_zero:N \parskip
      \keys_set:nn { vitae / entry } {#1}
      \__vitae_body_set:n {#2}
      \bool_lazy_and:nnF
        { \tl_if_blank_p:V \l__vitae_f_start_tl }
        { \tl_if_blank_p:V \l__vitae_f_end_tl }
        {
          \tl_set:Nx \l__vitae_f_dates_tl
            {
              \exp_not:N \daterange
                { \exp_not:V \l__vitae_f_start_tl }
                { \exp_not:V \l__vitae_f_end_tl }
            }
        }
      % "duration": only if enabled, for a real range (not a single date)
      % that has a length.
      \bool_lazy_and:nnT
        { \l__vitae_durations_bool }
        { ! \tl_if_eq_p:NN \l__vitae_f_start_tl \l__vitae_f_end_tl }
        {
          \int_compare:nNnT
            {
              \exp_args:NVV \__vitae_duration:nnN \l__vitae_f_start_tl
                \l__vitae_f_end_tl \__vitae_duration_length:nn + 0
            } > { 0 }
            {
              \tl_set:Nx \l__vitae_f_duration_tl
                {
                  \exp_not:N \duration
                    { \exp_not:V \l__vitae_f_start_tl }
                    { \exp_not:V \l__vitae_f_end_tl }
                }
            }
        }
      \__vitae_entry_template:
    \group_end:
  }
% The template for the current style: "entry" if blank or "full", else
% "entry/<style>". A style without a template warns once per style and
% falls back to "entry".
\clist_new:N \g__vitae_warned_styles_clist
\cs_new_protected:Npn \__vitae_entry_template:
  {
    \bool_lazy_or:nnTF
      { \tl_if_blank_p:V \l__vitae_entry_style_tl }
      { \str_if_eq_p:Vn \l__vitae_entry_style_tl { full } }
      { \__vitae_template_use:n { entry } }
      {
        \cs_if_exist:cTF { __vitae_template_entry/ \l__vitae_entry_style_tl : }
          { \__vitae_template_use:n { entry/ \l__vitae_entry_style_tl } }
          {
            \clist_if_in:NVF \g__vitae_warned_styles_clist \l__vitae_entry_style_tl
              {
                \clist_gput_right:NV \g__vitae_warned_styles_clist \l__vitae_entry_style_tl
                \msg_warning:nnV { vitae } { unknown-style } \l__vitae_entry_style_tl
              }
            \__vitae_template_use:n { entry }
          }
      }
  }
% \cvitem{<label>}{<text>}: a one-line item (skills, languages, ...).
\NewDocumentCommand \cvitem { m +m }
  {
    \group_begin:
      \skip_zero:N \parskip
      \tl_set:Nn \l__vitae_f_label_tl {#1}
      \__vitae_body_set:n {#2}
      \__vitae_template_use:n { item }
    \group_end:
  }

% \printentries[<options>]{<list>}: options are key=value (heading, icon,
% style, durations); the argument is a plain heading unless it contains
% "=" or its first item is an option name (as in [durations]). The heading
% appears only if the list has content; an empty or undefined list warns
% and prints nothing. Options are local to this call. With region=<name>
% the call is routed to that region (see vitaecore), as a call with
% region=main, which prints when the theme places the region.
\tl_new:N \l__vitae_print_heading_tl
\tl_new:N \l__vitae_print_icon_tl
\tl_new:N \l__vitae_print_region_tl
\keys_define:nn { vitae / print }
  {
    heading .tl_set:N = \l__vitae_print_heading_tl ,
    icon    .tl_set:N = \l__vitae_print_icon_tl ,
    style   .tl_set:N = \l__vitae_entry_style_tl ,
    region  .tl_set:N = \l__vitae_print_region_tl ,
    region  .initial:n = main ,
    durations .meta:nn = { vitae / setup } { durations = {#1} } ,
    durations .default:n = true ,
  }
\NewDocumentCommand \printentries { o m }
  {
    \group_begin:
      \IfValueT {#1}
        {
          \tl_if_in:nnTF {#1} { = }
            { \keys_set:nn { vitae / print } {#1} }
            {
              \exp_args:Nne \keys_if_exist:nnTF { vitae / print }
                { \clist_item:nn {#1} { 1 } }
                { \keys_set:nn { vitae / print } {#1} }
                { \tl_set:Nn \l__vitae_print_heading_tl {#1} }
            }
        }
      \__vitae_region:Vnn \l__vitae_print_region_tl
        { \printentries [ #1 , region = main ] {#2} }
        {
          \bool_lazy_and:nnTF
            { \seq_if_exist_p:c { g__vitae_list_#2_seq } }
            { ! \seq_if_empty_p:c { g__vitae_list_#2_seq } }
            {
              \tl_if_blank:VF \l__vitae_print_heading_tl
                {
                  \use:e
                    {
                      \exp_not:N \section
                        [ icon = { \exp_not:V \l__vitae_print_icon_tl } ]
                        { \exp_not:V \l__vitae_print_heading_tl }
                    }
                }
              \seq_use:cn { g__vitae_list_#2_seq } { }
            }
            { \msg_warning:nnn { vitae } { empty-list } {#2} }
        }
    \group_end:
  }
