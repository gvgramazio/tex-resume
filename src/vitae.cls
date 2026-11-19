%% vitae.cls -- a LaTeX class for building resumes.
%% Content is stored by this class; look and feel come from vitaetheme<name>.sty.
%% Distributed under the MIT license (see LICENSE).

% --- Identification -------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass{vitae}{2026-11-15}{0.2.0}{Resume class}

% --- Options and base class -----------------------------------------------
% Defaults first, user options after: the last paper/size option wins.
\PassOptionsToClass { a4paper, 11pt } { article }
\DeclareOption* { \PassOptionsToClass { \CurrentOption } { article } }
\ProcessOptions \relax
\LoadClass { article }

% --- Packages -------------------------------------------------------------
% pdfTeX needs T1 for accented names; Unicode engines use TU by default.
\sys_if_engine_pdftex:T { \RequirePackage [ T1 ] { fontenc } }
\RequirePackage { geometry }
\RequirePackage { xcolor }
\RequirePackage { graphicx }
\RequirePackage { fontawesome5 }
\RequirePackage { hyperref }
\RequirePackage { accsupp }
\hypersetup { hidelinks , pdfdisplaydoctitle }
\urlstyle { same }

% Resume defaults; themes may override.
\geometry { margin = 2cm }
\setlength \parindent { 0pt }
\pagestyle { empty }

% --- Variants -------------------------------------------------------------
\prg_generate_conditional_variant:Nnn \tl_if_blank:n { v , e } { T , F , TF }
\cs_generate_variant:Nn \str_set_convert:Nnnn { NeVn }
\cs_generate_variant:Nn \msg_warning:nnn { nnV }
\cs_generate_variant:Nn \msg_error:nnnn { nnVn }

% --- Messages -------------------------------------------------------------
\msg_new:nnn { vitae } { unknown-field } { Unknown~field~'#1'. }
\msg_new:nnn { vitae } { unknown-template } { Unknown~template~'#1'. }
\msg_new:nnn { vitae } { unknown-theme }
  { Theme~'#1'~not~found~(no~file~vitaetheme#1.sty). }
\msg_new:nnn { vitae } { second-theme }
  { Theme~'#1'~already~loaded;~'#2'~ignored. }
\msg_new:nnn { vitae } { empty-list } { List~'#1'~is~empty~or~undefined. }
\msg_new:nnn { vitae } { tagging-engine }
  {
    Tagged~PDF~is~supported~with~LuaLaTeX~only:~on~this~engine~the~boxes~
    vitae~layouts~use~are~not~tagged~correctly.~Text~extraction~is~
    unaffected.
  }
\msg_new:nnn { vitae } { unknown-style }
  { Entry~style~'#1'~has~no~template~'entry/#1';~the~default~is~used. }
\msg_new:nnn { vitae } { photo-missing } { Photo~'#1'~not~found;~skipped. }
\msg_new:nnn { vitae } { no-name }
  { No~name~set;~use~\iow_char:N\\name{First}{Last}. }

% --- Setup keys -----------------------------------------------------------
% \vitaesetup keys are remembered so they can be re-applied after a theme
% has set its own defaults: user choices always win.
\tl_new:N \g__vitae_setup_tl
\tl_new:N \l__vitae_present_tl
\tl_new:N \l__vitae_datesep_tl
\dim_new:N \vitaephotowidth
\skip_new:N \l__vitae_parskip_skip
\colorlet { vitaeaccent } { black }
\keys_define:nn { vitae / setup }
  {
    accent     .code:n    = \colorlet { vitaeaccent } {#1} ,
    present    .tl_set:N  = \l__vitae_present_tl ,
    datesep    .tl_set:N  = \l__vitae_datesep_tl ,
    datesep    .initial:n = \,--\allowbreak\, ,  % may break after the dash
    photowidth .dim_set:N = \vitaephotowidth ,
    photowidth .initial:n = 2.5cm ,
    % Space between paragraphs: sets \parskip for free text and the space
    % between paragraphs of entry and item bodies (see \__vitae_par:).
    parskip    .code:n    =
      {
        \skip_set:Nn \l__vitae_parskip_skip {#1}
        \skip_set_eq:NN \parskip \l__vitae_parskip_skip
      } ,
    parskip    .initial:n = 0.5\baselineskip plus 2pt ,
  }
\NewDocumentCommand \vitaesetup { m }
  {
    \tl_gput_right:Nn \g__vitae_setup_tl { #1 , }
    \keys_set:nn { vitae / setup } {#1}
  }

% --- Personal data --------------------------------------------------------
% Each field <f> gets a setter \<f>{...}, an expandable getter \the<f> and
% storage \g__vitae_field_<f>_tl. Text fields keep TeX material; string
% fields (URLs, handles, files) are stored as plain characters.
\cs_new_protected:Npn \__vitae_new_field:nn #1#2
  {
    \tl_new:c { g__vitae_field_#1_tl }
    \exp_args:Nc \NewDocumentCommand {#1} { m } { #2 {#1} {##1} }
    \cs_new:cpn { the#1 } { \tl_use:c { g__vitae_field_#1_tl } }
  }
\cs_new_protected:Npn \__vitae_set_text:nn #1#2
  { \tl_gset:cn { g__vitae_field_#1_tl } {#2} }
% Strings: _ & ~ # work as typed; the escapes \_ \& \# \% are also accepted
% (a raw % starts a comment, as everywhere in LaTeX). A normal argument, not
% a verbatim one, so setters also work inside other commands' arguments.
\str_new:N \l__vitae_tmp_str
\cs_generate_variant:Nn \str_replace_all:Nnn { Nee }
\cs_new_protected:Npn \__vitae_set_string:nn #1#2
  {
    \str_set:Nn \l__vitae_tmp_str {#2}
    \str_replace_all:Nee \l__vitae_tmp_str
      { \c_hash_str \c_hash_str } { \c_hash_str }
    \tl_map_inline:nn { \_ \& \# \% }
      {
        \str_replace_all:Nee \l__vitae_tmp_str
          { \tl_to_str:n {##1} } { \str_tail:n {##1} }
      }
    \tl_gset_eq:cN { g__vitae_field_#1_tl } \l__vitae_tmp_str
  }
\clist_map_inline:nn { firstname, lastname, jobtitle, address, phone }
  { \__vitae_new_field:nn {#1} { \__vitae_set_text:nn } }
\clist_map_inline:nn { email, homepage, linkedin, github, orcid, photo }
  { \__vitae_new_field:nn {#1} { \__vitae_set_string:nn } }
\NewDocumentCommand \name { m m } { \firstname {#1} \lastname {#2} }

% \ifvitaeset{<f>}{<true>}{<false>}: is the personal field <f> non-blank?
\NewExpandableDocumentCommand \ifvitaeset { m +m +m }
  {
    \tl_if_exist:cTF { g__vitae_field_#1_tl }
      { \tl_if_blank:vTF { g__vitae_field_#1_tl } {#3} {#2} }
      { \msg_expandable_error:nnn { vitae } { unknown-field } {#1} }
  }

% --- Template fields ------------------------------------------------------
% Templates read the current item through \field{<f>} and \iffield. Every
% writer sets them inside a group, so values never leak between items.
% (\cs_if_exist_use:c is avoided: it breaks \MakeUppercase on LuaTeX.)
\clist_map_inline:nn
  { title, org, location, start, end, dates, body, label, icon, text, url }
  { \tl_new:c { l__vitae_f_#1_tl } }
\NewExpandableDocumentCommand \field { m }
  {
    \tl_if_exist:cTF { l__vitae_f_#1_tl }
      { \tl_use:c { l__vitae_f_#1_tl } }
      { \msg_expandable_error:nnn { vitae } { unknown-field } {#1} }
  }
\NewExpandableDocumentCommand \iffield { m +m +m }
  {
    \tl_if_exist:cTF { l__vitae_f_#1_tl }
      { \tl_if_blank:vTF { l__vitae_f_#1_tl } {#3} {#2} }
      { \msg_expandable_error:nnn { vitae } { unknown-field } {#1} }
  }
% \ifanyfield{<field>, ...}{<true>}{<false>}: is any of the fields set?
\cs_new:Npn \__vitae_any_field:n #1 { \iffield {#1} { x } { } }
\NewExpandableDocumentCommand \ifanyfield { m +m +m }
  {
    \tl_if_blank:eTF { \clist_map_function:nN {#1} \__vitae_any_field:n }
      {#3} {#2}
  }
% \addpunct{<p>}: <p>, unless no text precedes it or the text already ends
% in sentence punctuation (space factor above 1000, as amsthm's \@addpunct).
\NewDocumentCommand \addpunct { m }
  {
    \mode_if_horizontal:T
      { \int_compare:nNnF { \tex_spacefactor:D } > { 1000 } {#1} }
  }
% \joinfields{<sep>}{<field>, <field>=<format>, ...}: the fields that are
% set, in order, each wrapped in its optional one-argument <format> (e.g.
% \textbf), separated by <sep>. Blank fields leave no stray separator.
\seq_new:N \l__vitae_join_seq
\cs_new_protected:Npn \__vitae_join_add:nn #1#2
  {
    \tl_if_exist:cTF { l__vitae_f_#1_tl }
      {
        \tl_if_blank:vF { l__vitae_f_#1_tl }
          { \seq_put_right:Nn \l__vitae_join_seq { #2 { \field {#1} } } }
      }
      { \msg_error:nnn { vitae } { unknown-field } {#1} }
  }
\cs_new_protected:Npn \__vitae_join_plain:n #1 { \__vitae_join_add:nn {#1} { } }
\NewDocumentCommand \joinfields { m m }
  {
    \group_begin:
      \seq_clear:N \l__vitae_join_seq
      \keyval_parse:NNn \__vitae_join_plain:n \__vitae_join_add:nn {#2}
      \seq_use:Nn \l__vitae_join_seq {#1}
    \group_end:
  }

% --- Dates ----------------------------------------------------------------
% \formatdate{<d>} renders ISO dates (YYYY, YYYY-MM, YYYY-MM-DD) in the
% current style and locale; anything else is returned unchanged. Style and
% locale are local settings: a group limits them to part of the document.
% Everything in this section is expandable unless noted.
\tl_new:N \l__vitae_date_style_tl
\tl_new:N \l__vitae_date_locale_tl
\msg_new:nnn { vitae } { unknown-date-locale }
  {
    No~date~locale~'#1';~English~is~used.~
    Define~one~with~\iow_char:N\\vitaedatelocale.
  }
\keys_define:nn { vitae / setup }
  {
    dateformat .choices:nn =
      { long , short , numeric , iso , year }
      { \tl_set:Nn \l__vitae_date_style_tl {#1} } ,
    dateformat .initial:n = long ,
    % Empty (default): follow \languagename (babel/polyglossia).
    datelocale .code:n =
      {
        \tl_set:Nn \l__vitae_date_locale_tl {#1}
        \tl_if_blank:nF {#1}
          {
            \tl_if_exist:cF { g__vitae_date_alias_#1_tl }
              { \msg_warning:nnn { vitae } { unknown-date-locale } {#1} }
          }
      } ,
  }

% \__vitae_if_digits:nn {<n>} {<text>}: exactly <n> ASCII digits?
\prg_new_conditional:Npnn \__vitae_if_digits:nn #1#2 { p }
  {
    \bool_lazy_and:nnTF
      { \int_compare_p:nNn { \str_count:n {#2} } = {#1} }
      { \str_if_eq_p:ee { \str_map_function:nN {#2} \__vitae_nondigit:n } { } }
      { \prg_return_true: } { \prg_return_false: }
  }
\cs_new:Npn \__vitae_nondigit:n #1
  { \str_case:nnF {#1} { {0}{} {1}{} {2}{} {3}{} {4}{} {5}{} {6}{} {7}{} {8}{} {9}{} } { x } }
% \__vitae_if_part:nn {<max>} {<text>}: two digits between 01 and <max>?
\prg_new_conditional:Npnn \__vitae_if_part:nn #1#2 { p }
  {
    \bool_lazy_and:nnTF
      { \__vitae_if_digits_p:nn { 2 } {#2} }
      { \int_compare_p:n { 1 <= #2 <= #1 } }
      { \prg_return_true: } { \prg_return_false: }
  }

% Parsing: the input as a string (so active characters cannot interfere) is
% split at "-" and accepted only if it rebuilds exactly as YYYY[-MM[-DD]].
\NewExpandableDocumentCommand \formatdate { m }
  { \tl_trim_spaces_apply:nN {#1} \__vitae_date_format:n }
\cs_new:Npn \__vitae_date_format:n #1
  { \exp_args:Ne \__vitae_date_parse:nn { \tl_to_str:n {#1} } {#1} }
\cs_new:Npn \__vitae_date_parse:nn #1#2 { \__vitae_date_split:w #1 - - - \q_stop {#2} }
\cs_new:Npn \__vitae_date_split:w #1 - #2 - #3 - #4 \q_stop #5
  {
    \bool_lazy_all:nTF
      {
        { \__vitae_if_digits_p:nn { 4 } {#1} }
        { \bool_lazy_or_p:nn { \tl_if_blank_p:n {#2} } { \__vitae_if_part_p:nn { 12 } {#2} } }
        { \bool_lazy_or_p:nn { \tl_if_blank_p:n {#3} } { \__vitae_if_part_p:nn { 31 } {#3} } }
        {
          \str_if_eq_p:ee { \tl_to_str:n {#5} }
            { #1 \tl_if_blank:nF {#2} { - #2 \tl_if_blank:nF {#3} { - #3 } } }
        }
      }
      { \__vitae_date_render:nnn {#1} {#2} {#3} }
      {#5}
  }

% Rendering: a year alone is always the year; otherwise the style decides.
\cs_new:Npn \__vitae_date_render:nnn #1#2#3
  {
    \tl_if_blank:nTF {#2} {#1}
      { \use:c { __vitae_date_style_ \l__vitae_date_style_tl :nnn } {#1} {#2} {#3} }
  }
\cs_new:Npn \__vitae_date_style_iso:nnn #1#2#3
  { #1 - #2 \tl_if_blank:nF {#3} { - #3 } }
\cs_new:Npn \__vitae_date_style_year:nnn #1#2#3 {#1}
\cs_new:Npn \__vitae_date_style_long:nnn { \__vitae_date_named:nnnn { months } }
\cs_new:Npn \__vitae_date_style_short:nnn { \__vitae_date_named:nnnn { short } }
\cs_new:Npn \__vitae_date_style_numeric:nnn #1#2#3
  { \__vitae_date_pattern:nnnn { \tl_if_blank:nTF {#3} { nym } { nymd } } {#1} {#2} {#3} }
% Named styles: month name from list #1, day without leading zero.
\cs_new:Npn \__vitae_date_named:nnnn #1#2#3#4
  {
    \__vitae_date_pattern:nnnn { \tl_if_blank:nTF {#4} { ym } { ymd } } {#2}
      { \clist_item:cn { g__vitae_date_ \__vitae_date_locale: _#1_clist } {#3} }
      { \tl_if_blank:nF {#4} { \int_eval:n {#4} } }
  }
\cs_new:Npn \__vitae_date_pattern:nnnn #1
  { \use:c { __vitae_date_ \__vitae_date_locale: _#1:nnn } }

% Current locale: datelocale if set, else \languagename; unknown -> english.
\cs_new:Npn \__vitae_date_locale:
  {
    \exp_args:Ne \__vitae_date_resolve:n
      {
        \tl_if_blank:VTF \l__vitae_date_locale_tl
          { \cs_if_exist:NTF \languagename { \languagename } { english } }
          { \tl_use:N \l__vitae_date_locale_tl }
      }
  }
\cs_new:Npn \__vitae_date_resolve:n #1
  {
    \tl_if_exist:cTF { g__vitae_date_alias_#1_tl }
      { \tl_use:c { g__vitae_date_alias_#1_tl } } { english }
  }
% "Present": the present key if set, else the locale's word.
\cs_new:Npn \__vitae_date_present:
  {
    \tl_if_blank:VTF \l__vitae_present_tl
      { \tl_use:c { g__vitae_date_ \__vitae_date_locale: _present_tl } }
      { \tl_use:N \l__vitae_present_tl }
  }

% \daterange{<start>}{<end>}: "s -- e", "s -- present" if no end, a single
% date if only one is given or both are equal, nothing if both are blank.
\NewExpandableDocumentCommand \daterange { m m }
  {
    \tl_if_blank:nTF {#1}
      { \tl_if_blank:nF {#2} { \formatdate {#2} } }
      {
        \formatdate {#1}
        \tl_if_blank:nTF {#2}
          { \tl_use:N \l__vitae_datesep_tl \__vitae_date_present: }
          {
            \str_if_eq:nnF {#1} {#2}
              { \tl_use:N \l__vitae_datesep_tl \formatdate {#2} }
          }
      }
  }

% --- Date locales ---------------------------------------------------------
% \vitaedatelocale{<name>}{<keys>} (not expandable) defines a locale,
% starting from English for any key not given. Patterns get #1 = year,
% #2 = month (name, or two digits in numeric-*), #3 = day (number, or two
% digits in numeric-*). "aliases" lists other \languagename values.
\keys_define:nn { vitae / datelocale }
  {
    months      .clist_set:N = \l__vitae_dl_months_clist ,
    short       .clist_set:N = \l__vitae_dl_short_clist ,
    present     .tl_set:N    = \l__vitae_dl_present_tl ,
    aliases     .clist_set:N = \l__vitae_dl_aliases_clist ,
    ym          .code:n = \cs_set:Npn \__vitae_dl_ym:nnn ##1##2##3 {#1} ,
    ymd         .code:n = \cs_set:Npn \__vitae_dl_ymd:nnn ##1##2##3 {#1} ,
    numeric-ym  .code:n = \cs_set:Npn \__vitae_dl_nym:nnn ##1##2##3 {#1} ,
    numeric-ymd .code:n = \cs_set:Npn \__vitae_dl_nymd:nnn ##1##2##3 {#1} ,
  }
\NewDocumentCommand \vitaedatelocale { m m }
  {
    \group_begin:
      \tl_if_exist:cT { g__vitae_date_alias_english_tl }
        { \__vitae_date_load:n { english } }
      \clist_clear:N \l__vitae_dl_aliases_clist
      \keys_set:nn { vitae / datelocale } {#2}
      \__vitae_date_save:n {#1}
      \clist_map_inline:Nn \l__vitae_dl_aliases_clist
        { \tl_gset:cn { g__vitae_date_alias_##1_tl } {#1} }
      \tl_gset:cn { g__vitae_date_alias_#1_tl } {#1}
    \group_end:
  }
% Stored locale <-> scratch record (\l__vitae_dl_... and \__vitae_dl_...).
\cs_new_protected:Npn \__vitae_date_load:n #1
  {
    \clist_map_inline:nn { months , short }
      { \clist_set_eq:cc { l__vitae_dl_##1_clist } { g__vitae_date_#1_##1_clist } }
    \tl_set_eq:Nc \l__vitae_dl_present_tl { g__vitae_date_#1_present_tl }
    \clist_map_inline:nn { ym , ymd , nym , nymd }
      { \cs_set_eq:cc { __vitae_dl_##1:nnn } { __vitae_date_#1_##1:nnn } }
  }
\cs_new_protected:Npn \__vitae_date_save:n #1
  {
    \clist_map_inline:nn { months , short }
      { \clist_gset_eq:cc { g__vitae_date_#1_##1_clist } { l__vitae_dl_##1_clist } }
    \tl_gset_eq:cN { g__vitae_date_#1_present_tl } \l__vitae_dl_present_tl
    \clist_map_inline:nn { ym , ymd , nym , nymd }
      { \cs_gset_eq:cc { __vitae_date_#1_##1:nnn } { __vitae_dl_##1:nnn } }
  }

% Built-in locales. English (US order) first: the base for all others.
\vitaedatelocale { english }
  {
    aliases     = { american , USenglish , canadian } ,
    months      = { January , February , March , April , May , June , July ,
                    August , September , October , November , December } ,
    short       = { Jan , Feb , Mar , Apr , May , Jun , Jul , Aug , Sep ,
                    Oct , Nov , Dec } ,
    present     = Present ,
    ym          = { #2 ~ #1 } ,
    ymd         = { #2 ~ #3 , ~ #1 } ,
    numeric-ym  = { #2 / #1 } ,
    numeric-ymd = { #2 / #3 / #1 } ,
  }
\vitaedatelocale { british }
  {
    aliases     = { UKenglish , australian , newzealand } ,
    ymd         = { #3 ~ #2 ~ #1 } ,
    numeric-ymd = { #3 / #2 / #1 } ,
  }
\vitaedatelocale { italian }
  {
    months      = { gennaio , febbraio , marzo , aprile , maggio , giugno ,
                    luglio , agosto , settembre , ottobre , novembre , dicembre } ,
    short       = { gen , feb , mar , apr , mag , giu , lug , ago , set , ott ,
                    nov , dic } ,
    present     = presente ,
    ymd         = { #3 ~ #2 ~ #1 } ,
    numeric-ymd = { #3 / #2 / #1 } ,
  }
\vitaedatelocale { german }
  {
    aliases     = { ngerman , austrian , naustrian , swissgerman , nswissgerman } ,
    months      = { Januar , Februar , März , April , Mai , Juni , Juli ,
                    August , September , Oktober , November , Dezember } ,
    short       = { Jan. , Feb. , März , Apr. , Mai , Juni , Juli , Aug. ,
                    Sept. , Okt. , Nov. , Dez. } ,
    present     = heute ,
    ymd         = { #3. ~ #2 ~ #1 } ,
    numeric-ymd = { #3 . #2 . #1 } ,
  }
\vitaedatelocale { french }
  {
    aliases     = { francais , frenchb , acadian } ,
    months      = { janvier , février , mars , avril , mai , juin , juillet ,
                    août , septembre , octobre , novembre , décembre } ,
    short       = { janv. , févr. , mars , avr. , mai , juin , juil. , août ,
                    sept. , oct. , nov. , déc. } ,
    present     = aujourd'hui ,
    % The first of the month is "1er". (A ~ starting a line would be lost.)
    ymd         = { \int_compare:nNnTF {#3} = { 1 } { 1\textsuperscript{er} } {#3} ~
                    #2 ~ #1 } ,
    numeric-ymd = { #3 / #2 / #1 } ,
  }
\vitaedatelocale { spanish }
  {
    months      = { enero , febrero , marzo , abril , mayo , junio , julio ,
                    agosto , septiembre , octubre , noviembre , diciembre } ,
    short       = { ene. , feb. , mar. , abr. , may. , jun. , jul. , ago. ,
                    sept. , oct. , nov. , dic. } ,
    present     = actualidad ,
    ym          = { #2 ~ de ~ #1 } ,
    ymd         = { #3 ~ de ~ #2 ~ de ~ #1 } ,
    numeric-ymd = { #3 / #2 / #1 } ,
  }

% --- Templates ------------------------------------------------------------
% A template is a parameterless macro \__vitae_template_<name>:. The class
% ships plain defaults; themes and users replace them via \settemplate.
\cs_new_protected:Npn \__vitae_template_use:n #1 { \use:c { __vitae_template_#1: } }
% Any "entry/<style>" name may be defined, which creates a new entry style.
\NewDocumentCommand \settemplate { m +m }
  {
    \bool_lazy_or:nnTF
      { \cs_if_exist_p:c { __vitae_template_#1: } }
      { \str_if_eq_p:ee { \str_range:nnn {#1} { 1 } { 6 } } { entry/ } }
      { \cs_set_protected:cpn { __vitae_template_#1: } {#2} }
      { \msg_error:nnn { vitae } { unknown-template } {#1} }
  }
\cs_new_protected:cpn { __vitae_template_header: }
  {
    \begin { center }
      \taggedheading { 1 } { { \LARGE \thefirstname \c_space_tl \thelastname \par } }
      \ifvitaeset { jobtitle } { \thejobtitle \par } { }
      \printcontacts
    \end { center }
  }
\cs_new_protected:cpn { __vitae_template_contact: }
  { \mbox { \field { icon } ~ \field { text } } }
\cs_new_protected:cpn { __vitae_template_contactsep: } { \quad }
\cs_new_protected:cpn { __vitae_template_section: }
  {
    \par \bigskip
    \taggedheading { 2 } { { \large \bfseries \field { title } \par } }
    \nopagebreak \medskip
  }
\cs_new_protected:cpn { __vitae_template_entry: }
  {
    \par \textbf { \field { title } } \hfill \field { dates } \par
    \iffield { org } { \field { org } \iffield { location } { , ~ \field { location } } { } \par } { }
    \iffield { body } { \field { body } \par } { }
    \medskip
  }
% Entry styles: "entry/<style>" templates, chosen with the style key.
\cs_new_protected:cpn { __vitae_template_entry/compact: }
  {
    \par \joinfields { , ~ } { title = \textbf , org , location } \hfill \field { dates } \par
    \iffield { body } { \field { body } \par } { }
    \smallskip
  }
\cs_new_protected:cpn { __vitae_template_entry/inline: }
  {
    \par
    \ifanyfield { title , org , location }
      {
        \joinfields { , ~ } { title = \textbf , org , location }
        \iffield { dates } { ~ ( \field { dates } ) } { }
      }
      { \field { dates } }
    \addpunct { . } \iffield { body } { \ifanyfield { title , org , location , dates } { ~ } { } } { }
    \field { body } \par
    \smallskip
  }
\cs_new_protected:cpn { __vitae_template_item: }
  { \par \textbf { \field { label } } : ~ \field { body } \par }

% --- Accessibility --------------------------------------------------------
% The PDF must read well for screen readers (tagged PDF, enabled by the
% document's \DocumentMetadata) and for text extraction (ATS), tagged or not.
% \actualtext{<text>}{<content>}: <content> is read and extracted as <text>
% (empty: as nothing), on every engine and with or without tagging. Two
% layers: marked-content ActualText (accsupp) serves plain text extraction,
% which ATS use and which ignores structure; under tagging, a Span structure
% element with the same ActualText (or an artifact, for empty <text>)
% serves assistive technology and PDF/UA.
\tl_new:N \l__vitae_actualtext_tl
% The text is passed as UTF-16 hex, the one encoding every driver
% (pdfTeX, LuaTeX, xdvipdfmx) writes faithfully; pdfTeX holds text as UTF-8
% bytes, the other engines as Unicode characters.
\str_new:N \l__vitae_actualtext_str
\str_const:Ne \c__vitae_text_encoding_str { \sys_if_engine_pdftex:T { utf8 } }
% XeTeX: xdvipdfmx writes replacement text where extraction reads it out of
% order (labels pile up later on the page), so there <content> is only
% hidden; use pdfTeX or LuaTeX for labelled output.
\cs_new_protected:Npn \__vitae_accsupp:nn #1#2
  {
    \str_set_convert:NeVn \l__vitae_actualtext_str
      { \sys_if_engine_xetex:F { \text_purify:n {#1} } }
      \c__vitae_text_encoding_str { utf16 / hex }
    \exp_args:Ne \BeginAccSupp
      { method = hex , ActualText = \l__vitae_actualtext_str }
    #2
    \EndAccSupp { }
  }
\NewDocumentCommand \actualtext { m +m }
  {
    \tag_if_active:TF
      {
        \tag_mc_end_push:
        \tl_if_blank:nTF {#1}
          {
            \tag_mc_begin:n { artifact }
            \__vitae_accsupp:nn { } {#2}
            \tag_mc_end:
          }
          {
            % tagpdf stores the value almost verbatim: give it plain text.
            \tl_set:Ne \l__vitae_actualtext_tl { \text_purify:n {#1} }
            \exp_args:Ne \tag_struct_begin:n
              { tag = Span , actualtext = { \exp_not:V \l__vitae_actualtext_tl } }
            \tag_mc_begin:n { }
            \__vitae_accsupp:nn {#1} {#2}
            \tag_mc_end:
            \tag_struct_end:
          }
        \tag_mc_begin_pop:n { }
      }
      { \__vitae_accsupp:nn {#1} {#2} }
  }
% \decorative{<material>}: rules and other drawn decoration; under tagging
% it is marked as an artifact (pdfTeX does not do that by itself).
\NewDocumentCommand \decorative { +m }
  {
    \tag_if_active:TF
      { \tag_mc_artifact_group_begin:n { notype } #1 \tag_mc_artifact_group_end: }
      {#1}
  }
% \taggedheading{<level>}{<material>}: under tagging, <material> (whole
% paragraphs) becomes a heading H<level> instead of P; otherwise a no-op.
\NewDocumentCommand \taggedheading { m +m }
  {
    \tag_if_active:TF
      {
        \par
        \tag_struct_begin:n { tag = H#1 }
        \tagpdfparaOff
        \tag_mc_begin:n { }
        #2
        \tag_mc_end:
        \tagpdfparaOn
        \tag_struct_end:
      }
      {#2}
  }
% pdfTeX: map every Font Awesome glyph to its Unicode code point, so the
% icon fonts carry a complete ToUnicode table (required by PDF/UA). The
% mapping file is read again with a collecting definition of its entries.
% Each mapping is scoped to the icon fonts ("tfm:<font>/<glyph>"): icons
% named "at", "slash" or "plus" must not remap @, / and + in text fonts.
\cs_new_protected:Npn \__vitae_fa_unicode:nnn #1#2#3
  { \pdfglyphtounicode { tfm: #1 / #2 } { \int_to_Hex:n {#3} } }
\sys_if_engine_pdftex:T
  {
    \group_begin:
      \cs_set_protected:Npn \__fontawesome_def_icon:nnnnn #1#2#3#4#5
        {
          \tl_if_in:nnTF {#3} { brands }
            { \__vitae_fa_unicode:nnn { fa5#3 } {#2} {#5} }
            {
              \__vitae_fa_unicode:nnn { fa5#3solid } {#2} {#5}
              \__vitae_fa_unicode:nnn { fa5#3regular } {#2} {#5}
            }
        }
      \file_input:n { fontawesome5-mapping.def }
    \group_end:
    \int_gset:Nn \pdfgentounicode { 1 }
  }
% A resume has no maths: skip LuaTeX's MathML generation under tagging
% (it would otherwise warn that unicode-math is not loaded).
\cs_if_exist:NT \tagpdfsetup
  { \sys_if_engine_luatex:T { \tagpdfsetup { math / mathml / luamml / load = false } } }

% --- Contacts -------------------------------------------------------------
% Contacts are built at \makeheader time as a sequence of
% \__vitae_contact:nnnn {<label>} {<icon>} {<url>} {<text>}: first the
% built-in fields (in a fixed order), then those added with \addcontact.
% The icon is read and extracted as "<label>:" (or not at all without a
% label), so "GitHub: jdoe-example" survives screen readers and ATS.
\seq_new:N \l__vitae_contacts_seq
\seq_new:N \g__vitae_extra_contacts_seq
\cs_new_protected:Npn \__vitae_contact:nnnn #1#2#3#4
  {
    \group_begin:
      \tl_if_blank:nTF {#1}
        { \tl_set:Nn \l__vitae_f_icon_tl { \actualtext { } {#2} } }
        { \tl_set:Nn \l__vitae_f_icon_tl { \actualtext { #1 : } {#2} } }
      \tl_set:Nn \l__vitae_f_url_tl {#3}
      \tl_if_blank:nTF {#3}
        { \tl_set:Nn \l__vitae_f_text_tl {#4} }
        { \tl_set:Nn \l__vitae_f_text_tl { \href {#3} {#4} } }
      \__vitae_template_use:n { contact }
    \group_end:
  }
% Text field: shown as typed, not linked. #1 field, #2 label, #3 icon.
\cs_new_protected:Npn \__vitae_contact_text:nnn #1#2#3
  {
    \tl_if_blank:vF { g__vitae_field_#1_tl }
      {
        \seq_put_right:Nx \l__vitae_contacts_seq
          {
            \exp_not:N \__vitae_contact:nnnn {#2} { \exp_not:n {#3} } { }
              { \exp_not:v { g__vitae_field_#1_tl } }
          }
      }
  }
% String field: linked to <prefix><value>, shown via \nolinkurl.
% #1 field, #2 label, #3 icon, #4 URL prefix. The prefix is made a string
% like the value: an expl3-typed "https://" (":" a letter) glued to a string
% makes hyperref write a GoToR file link instead of a URI.
\cs_new_protected:Npn \__vitae_contact_link:nnnn #1#2#3#4
  {
    \tl_if_blank:vF { g__vitae_field_#1_tl }
      {
        \seq_put_right:Nx \l__vitae_contacts_seq
          {
            \exp_not:N \__vitae_contact:nnnn {#2} { \exp_not:n {#3} }
              { \tl_to_str:n {#4} \exp_not:v { g__vitae_field_#1_tl } }
              { \exp_not:N \nolinkurl { \exp_not:v { g__vitae_field_#1_tl } } }
          }
      }
  }
\cs_new_protected:Npn \__vitae_contacts_collect:
  {
    \seq_clear:N \l__vitae_contacts_seq
    \__vitae_contact_link:nnnn { email } { Email } { \faEnvelope } { mailto: }
    \__vitae_contact_text:nnn { phone } { Phone } { \faPhone }
    \__vitae_contact_text:nnn { address } { Address } { \faMapMarker* }
    \__vitae_contact_link:nnnn { homepage } { Website } { \faGlobe } { https:// }
    \__vitae_contact_link:nnnn { linkedin } { LinkedIn } { \faLinkedin }
      { https://www.linkedin.com/in/ }
    \__vitae_contact_link:nnnn { github } { GitHub } { \faGithub } { https://github.com/ }
    \__vitae_contact_link:nnnn { orcid } { ORCID } { \faOrcid } { https://orcid.org/ }
    \seq_concat:NNN \l__vitae_contacts_seq
      \l__vitae_contacts_seq \g__vitae_extra_contacts_seq
  }
% \addcontact[<options>]{<icon>}{<text>}: any extra contact, appended in
% order. Options: url, label (read for the icon); without "=" the whole
% argument is the URL.
\tl_new:N \l__vitae_contact_url_tl
\tl_new:N \l__vitae_contact_label_tl
\keys_define:nn { vitae / contact }
  {
    url   .tl_set:N = \l__vitae_contact_url_tl ,
    label .tl_set:N = \l__vitae_contact_label_tl ,
  }
\NewDocumentCommand \addcontact { O { } m m }
  {
    \group_begin:
      \tl_clear:N \l__vitae_contact_url_tl
      \tl_clear:N \l__vitae_contact_label_tl
      \tl_if_in:nnTF {#1} { = }
        { \keys_set:nn { vitae / contact } {#1} }
        { \tl_set:Nn \l__vitae_contact_url_tl {#1} }
      \seq_gput_right:Nx \g__vitae_extra_contacts_seq
        {
          \exp_not:N \__vitae_contact:nnnn
            { \exp_not:V \l__vitae_contact_label_tl } { \exp_not:n {#2} }
            { \exp_not:V \l__vitae_contact_url_tl } { \exp_not:n {#3} }
        }
    \group_end:
  }
% \printcontacts: every contact, separated by the contactsep template.
\NewDocumentCommand \printcontacts { }
  {
    \group_begin:
      \__vitae_contacts_collect:
      % Separators are read and extracted as "; ", so contacts never run
      % together, whatever the theme draws.
      \seq_use:Nn \l__vitae_contacts_seq
        { \actualtext { ; ~ } { \__vitae_template_use:n { contactsep } } }
    \group_end:
  }

% --- Header and photo -----------------------------------------------------
% \printphoto: the photo at \vitaephotowidth; a missing file only warns.
% Without an extension, the usual graphics extensions are tried.
\bool_new:N \l__vitae_found_bool
\NewDocumentCommand \printphoto { }
  {
    \tl_if_blank:VF \g__vitae_field_photo_tl
      {
        \bool_set_false:N \l__vitae_found_bool
        \clist_map_inline:nn { .pdf, .png, .jpg, .jpeg }
          {
            \file_if_exist:nT { \g__vitae_field_photo_tl ##1 }
              { \bool_set_true:N \l__vitae_found_bool \clist_map_break: }
          }
        \file_if_exist:nT { \g__vitae_field_photo_tl }
          { \bool_set_true:N \l__vitae_found_bool }
        \bool_if:NTF \l__vitae_found_bool
          {
            \includegraphics
              [ width = \vitaephotowidth ,
                alt = { Photo~of~\thefirstname \c_space_tl \thelastname } ]
              { \g__vitae_field_photo_tl }
          }
          { \msg_warning:nnV { vitae } { photo-missing } \g__vitae_field_photo_tl }
      }
  }
% \makeheader: typeset the header template, like \maketitle.
\NewDocumentCommand \makeheader { }
  {
    \bool_lazy_and:nnT
      { \tl_if_blank_p:V \g__vitae_field_firstname_tl }
      { \tl_if_blank_p:V \g__vitae_field_lastname_tl }
      { \msg_warning:nn { vitae } { no-name } }
    \group_begin: \skip_zero:N \parskip \__vitae_template_use:n { header } \group_end:
  }

% --- Sections -------------------------------------------------------------
% \section[*]{<title>} goes through the section template (no numbering).
\RenewDocumentCommand \section { s o m }
  {
    \group_begin:
      \skip_zero:N \parskip
      \tl_set:Nn \l__vitae_f_title_tl {#3}
      \__vitae_template_use:n { section }
    \group_end:
  }

% --- Entries and items ----------------------------------------------------
% Structural groups (header, section, entry, item) run with \parskip = 0,
% so template lines keep their exact spacing whatever the setting. Blank
% lines in bodies become \__vitae_par:, which adds the configured space
% explicitly: it also works inside parboxes and lists, which reset \parskip.
\cs_new_protected:Npn \__vitae_par: { \par \addvspace { \l__vitae_parskip_skip } }
\cs_new_protected:Npn \__vitae_body_set:n #1
  {
    \tl_set:Nn \l__vitae_f_body_tl {#1}
    \tl_replace_all:Nnn \l__vitae_f_body_tl { \par } { \__vitae_par: }
  }
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
    datelocale .meta:nn = { vitae / setup } { datelocale = {#1} } ,
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

% --- Lists ----------------------------------------------------------------
% Named lists store unexpanded \cventry/\cvitem calls, printed in order.
\cs_new_protected:Npn \__vitae_list_put:nn #1#2
  {
    \seq_if_exist:cF { g__vitae_list_#1_seq } { \seq_new:c { g__vitae_list_#1_seq } }
    \seq_gput_right:cn { g__vitae_list_#1_seq } {#2}
  }
\NewDocumentCommand \addentry { m m +m } { \__vitae_list_put:nn {#1} { \cventry {#2} {#3} } }
\NewDocumentCommand \additem { m m +m } { \__vitae_list_put:nn {#1} { \cvitem {#2} {#3} } }
% \printentries[<options>]{<list>}: options are key=value (heading,
% style); without any "=" the whole argument is the heading. The heading
% appears only if the list has content; an empty or undefined list warns
% and prints nothing. Options are local to this call.
\tl_new:N \l__vitae_print_heading_tl
\keys_define:nn { vitae / print }
  {
    heading .tl_set:N = \l__vitae_print_heading_tl ,
    style   .tl_set:N = \l__vitae_entry_style_tl ,
  }
\NewDocumentCommand \printentries { o m }
  {
    \group_begin:
      \IfValueT {#1}
        {
          \tl_if_in:nnTF {#1} { = }
            { \keys_set:nn { vitae / print } {#1} }
            { \tl_set:Nn \l__vitae_print_heading_tl {#1} }
        }
      \bool_lazy_and:nnTF
        { \seq_if_exist_p:c { g__vitae_list_#2_seq } }
        { ! \seq_if_empty_p:c { g__vitae_list_#2_seq } }
        {
          \tl_if_blank:VF \l__vitae_print_heading_tl
            { \exp_args:NV \section \l__vitae_print_heading_tl }
          \seq_use:cn { g__vitae_list_#2_seq } { }
        }
        { \msg_warning:nnn { vitae } { empty-list } {#2} }
    \group_end:
  }

% --- Themes ---------------------------------------------------------------
% \usetheme{<name>} loads vitaetheme<name>.sty once, then re-applies user
% \vitaesetup keys over the theme defaults. Without \usetheme, "classic"
% is loaded at the end of the preamble.
\tl_new:N \g__vitae_theme_tl
\NewDocumentCommand \usetheme { m }
  {
    \tl_if_empty:NTF \g__vitae_theme_tl
      {
        \file_if_exist:nTF { vitaetheme#1.sty }
          {
            \tl_gset:Nn \g__vitae_theme_tl {#1}
            \RequirePackage { vitaetheme#1 }
            \keys_set:nV { vitae / setup } \g__vitae_setup_tl
          }
          { \msg_error:nnn { vitae } { unknown-theme } {#1} }
      }
      {
        \tl_if_eq:NnF \g__vitae_theme_tl {#1}
          { \msg_error:nnVn { vitae } { second-theme } \g__vitae_theme_tl {#1} }
      }
  }
\@onlypreamble \usetheme
\hook_gput_code:nnn { begindocument / before } { vitae }
  {
    \tl_if_empty:NT \g__vitae_theme_tl { \usetheme { classic } }
    % Tagging (\DocumentMetadata) is validated on LuaTeX only.
    \tag_if_active:T
      { \sys_if_engine_luatex:F { \msg_warning:nn { vitae } { tagging-engine } } }
    % The main language (babel/polyglossia) should have a date locale.
    \bool_lazy_and:nnT
      { \tl_if_blank_p:V \l__vitae_date_locale_tl }
      { \cs_if_exist_p:N \languagename }
      {
        \tl_if_exist:cF { g__vitae_date_alias_ \languagename _tl }
          { \msg_warning:nnV { vitae } { unknown-date-locale } \languagename }
      }
    % Document title (shown by viewers; required by PDF/UA): the name,
    % followed by the job title if set.
    \hypersetup
      {
        pdfauthor = { \thefirstname \c_space_tl \thelastname } ,
        pdftitle  =
          {
            \thefirstname \c_space_tl \thelastname
            \ifvitaeset { jobtitle } { \c_space_tl \textendash \c_space_tl \thejobtitle } { }
          } ,
      }
  }
