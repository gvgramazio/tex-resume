%% vitaeletter.cls -- a cover letter that matches a vitae resume.
%% Same data, header and theme as vitae.cls; see vitaecore.sty.
%% Distributed under the MIT license (see LICENSE).

% --- Identification -------------------------------------------------------
\NeedsTeXFormat{LaTeX2e}[2022-06-01]
\ProvidesExplClass{vitaeletter}{2026-11-22}{0.5.0}{Cover letter class}

% --- Options and base class -----------------------------------------------
% Defaults first, user options after: the last paper/size option wins.
\PassOptionsToClass { a4paper, 11pt } { article }
\DeclareOption* { \PassOptionsToClass { \CurrentOption } { article } }
\ProcessOptions \relax
\LoadClass { article }
% Identity, contacts, dates, templates and themes, shared with vitae.
\RequirePackage { vitaecore }

% --- Letter data ----------------------------------------------------------
% \recipient{<name>}{<address>} (lines separated by \\) and
% \letterdate{<ISO date>}: stored for \opening. The date defaults to the
% day of compilation; \letterdate{} leaves it out.
\tl_new:N \g__vitae_recipient_name_tl
\tl_new:N \g__vitae_recipient_address_tl
\tl_new:N \g__vitae_letterdate_tl
\tl_gset:Ne \g__vitae_letterdate_tl
  {
    \int_use:N \c_sys_year_int -
    \int_compare:nNnT \c_sys_month_int < { 10 } { 0 } \int_use:N \c_sys_month_int -
    \int_compare:nNnT \c_sys_day_int < { 10 } { 0 } \int_use:N \c_sys_day_int
  }
\NewDocumentCommand \recipient { m m }
  {
    \tl_gset:Nn \g__vitae_recipient_name_tl {#1}
    \tl_gset:Nn \g__vitae_recipient_address_tl {#2}
  }
\NewDocumentCommand \letterdate { m } { \tl_gset:Nn \g__vitae_letterdate_tl {#1} }

% --- Opening and closing --------------------------------------------------
% \opening{<salutation>}: the header (as in the resume), then the opening
% template with the recipient, the date (through \formatdate, so it follows
% the date style and locale) and the salutation.
\NewDocumentCommand \opening { m }
  {
    \makeheader
    \group_begin:
      \skip_zero:N \parskip
      \tl_set_eq:NN \l__vitae_f_name_tl \g__vitae_recipient_name_tl
      \tl_set_eq:NN \l__vitae_f_address_tl \g__vitae_recipient_address_tl
      \tl_if_blank:VF \g__vitae_letterdate_tl
        { \tl_set:Ne \l__vitae_f_date_tl { \exp_not:N \formatdate { \exp_not:V \g__vitae_letterdate_tl } } }
      \tl_set:Nn \l__vitae_f_text_tl {#1}
      \__vitae_template_use:n { opening }
    \group_end:
  }
% \closing{<text>}: the closing template, which also signs the letter.
\NewDocumentCommand \closing { m }
  {
    \group_begin:
      \skip_zero:N \parskip
      \tl_set:Nn \l__vitae_f_text_tl {#1}
      \__vitae_template_use:n { closing }
    \group_end:
  }
