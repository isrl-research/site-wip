%% isrl-report.cls
%% Interdisciplinary Systems Research Lab (iSRL)
%% Version: 5.3 — 2026
%%
%% TWO MODES (set once at \documentclass):
%%   \documentclass{isrl-report}            — everything full-width (default)
%%   \documentclass[sidenotes]{isrl-report} — body pages narrow + right margin
%%
%% In BOTH modes the following are ALWAYS full-width:
%%   cover page · TOC · References section · header rule
%%
%% COVER / OPENING PAGE STRUCTURE:
%%   Cover (unnumbered):  logo(s) | title | authors | date |
%%                        thin rule | contributors | reviewers | license
%%   Page 1:              abstract (framed) + TOC
%%
%% USAGE IN .tex:
%%   \maketitle                              — unnumbered cover
%%   \makeabstractpage{Abstract text here}  — page 1: abstract + TOC
%%
%%   Optional collab logo:  \collablogo{filename.png}
%%   \coverabstract{} still accepted but silently ignored (backward compat)
%%
%% CHANGES IN v5.3:
%%   - Abstract moved off cover to page 1 via \makeabstractpage{text}
%%   - Cover is identity-only: title · authors · contributors · reviewers
%%   - Two-logo support via \collablogo{filename}
%%   - Cover uses upper/lower zone with genuine breathing room between
%%
%% CHANGES IN v5.2:
%%   - Fixed cover page-break via minipage[t][\textheight][t]
%%
%% CHANGES IN v5.1:
%%   - Fixed \cite via aux-based two-pass resolution
%%   - Added CRediT contributor/reviewer system

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{isrl-report}[2026/03/21 iSRL Report Class v5.3]

%% ============================================================
%%  OPTIONS
%% ============================================================

\newif\ifisrl@sidenotes
\isrl@sidenotesfalse
\DeclareOption{sidenotes}{\isrl@sidenotestrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax
\LoadClass[12pt,a4paper]{article}

%% ============================================================
%%  PACKAGES
%% ============================================================

\RequirePackage{geometry}
\RequirePackage{xcolor}
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{microtype}
\RequirePackage{setspace}
\RequirePackage{parskip}
\RequirePackage{graphicx}
\RequirePackage{ifthen}
\RequirePackage{fancyhdr}
\RequirePackage{titlesec}
\RequirePackage{tocloft}
\RequirePackage{booktabs}
\RequirePackage{caption}
\RequirePackage{mdframed}
\RequirePackage{ragged2e}
\RequirePackage{etoolbox}
\RequirePackage{marginnote}
\RequirePackage{mparhack}
\RequirePackage{sidenotes}
\RequirePackage{enumitem}
\RequirePackage{changepage}   % for adjustwidth in fullwidth env
\RequirePackage{array}        % for cover CRediT table

% hyperref last
\RequirePackage[
  colorlinks=true,
  linkcolor=NavyColor, citecolor=NavyColor, urlcolor=NavyColor,
  pdfborder={0 0 0}, pdfencoding=auto, unicode=true,
]{hyperref}

%% ============================================================
%%  COLOURS
%% ============================================================

\definecolor{BgColor}{HTML}{f7f6f2}
\definecolor{InkColor}{HTML}{111110}
\definecolor{NavyColor}{HTML}{2c346b}
\definecolor{RedColor}{HTML}{c0392b}
\definecolor{FolioGray}{HTML}{555554}   % page numbers + cover doc-id ONLY

%% ============================================================
%%  GEOMETRY
%% ============================================================

\newlength{\isrl@right}      \setlength{\isrl@right}{62mm}
\newlength{\isrl@mparwidth}  \setlength{\isrl@mparwidth}{46mm}
\newlength{\isrl@mparsep}    \setlength{\isrl@mparsep}{6mm}

\newcommand{\isrl@setbodygeometry}{%
  \ifisrl@sidenotes
    \newgeometry{%
      top=26mm, bottom=28mm, left=22mm, right=\isrl@right,
      marginparwidth=\isrl@mparwidth, marginparsep=\isrl@mparsep,
      headheight=15pt, headsep=7mm, footskip=0pt,
    }%
    \setlength{\marginparwidth}{\isrl@mparwidth}%
    \setlength{\marginparsep}{\isrl@mparsep}%
    \setlength{\headwidth}{\dimexpr\textwidth+\isrl@right\relax}%
  \else
    \newgeometry{%
      top=26mm, bottom=28mm, left=22mm, right=22mm,
      headheight=15pt, headsep=7mm, footskip=0pt,
    }%
        \setlength{\headwidth}{\textwidth}

  \fi
}

\AtBeginDocument{\isrl@setbodygeometry}

%% ── Background ───────────────────────────────────────────────────────────
\RequirePackage{pagecolor}
\pagecolor{BgColor}
\color{InkColor}

%% ============================================================
%%  SIDENOTE BEHAVIOUR
%% ============================================================

\ifisrl@sidenotes
  \renewcommand*{\marginfont}{\footnotesize\color{InkColor}\RaggedRight}
\else
  \renewcommand{\sidenote}[2][]{\footnote{#2}}%
\fi

%% ============================================================
%%  TYPOGRAPHY
%% ============================================================

\setstretch{1.25}
\setlength{\parindent}{0pt}
\setlength{\parskip}{9pt plus 2pt minus 1pt}
\microtypesetup{expansion=false, protrusion=true}

%% ============================================================
%%  CITATION SYSTEM
%%
%%  Two-pass aux-based resolution. On first compile, \bibitem
%%  writes \bibstorenum{key}{N} to the .aux file. On second
%%  compile, those entries are read back at \begin{document}
%%  so \cite{key} resolves correctly everywhere — including
%%  inside \coverabstract which runs before \begin{references}.
%%
%%  Always compile twice after adding or reordering references.
%% ============================================================

%% Command written to .aux — executed on the next run to populate
%% the bib@num@<key> namespace before any \cite is processed.
\newcommand{\bibstorenum}[2]{%
  \expandafter\gdef\csname bib@num@#1\endcsname{#2}%
}

%% \cite{key} — reads from bib@num@ namespace; shows [?] if not yet resolved
\renewcommand{\cite}[1]{%
  \ifcsname bib@num@#1\endcsname
    \hyperref[bib:#1]{[\csname bib@num@#1\endcsname]}%
  \else
    \textbf{[?]}%
  \fi
}

%% ============================================================
%%  MULTI-AUTHOR SYSTEM
%% ============================================================

\newcounter{isrl@authorcount}
\setcounter{isrl@authorcount}{0}

\newcommand{\addauthor}[2]{%
  \stepcounter{isrl@authorcount}%
  \expandafter\def\csname isrl@name@\theisrl@authorcount\endcsname{#1}%
  \expandafter\def\csname isrl@affil@\theisrl@authorcount\endcsname{#2}%
}

\newcommand{\isrl@rendernames}{%
  \@tempcnta=1\relax
  \loop\ifnum\@tempcnta>\value{isrl@authorcount}\else
    \ifnum\@tempcnta>1 ,\quad\fi
    \csname isrl@name@\the\@tempcnta\endcsname
    \textsuperscript{\the\@tempcnta}%
    \advance\@tempcnta\@ne
  \repeat
}

\newcommand{\isrl@renderaffils}{%
  \@tempcnta=1\relax
  \loop\ifnum\@tempcnta>\value{isrl@authorcount}\else
    \ifnum\@tempcnta>1 \\[3pt]\fi
    \the\@tempcnta.\hspace{4pt}%
    \csname isrl@affil@\the\@tempcnta\endcsname
    \advance\@tempcnta\@ne
  \repeat
}

%% ============================================================
%%  CREDIT CONTRIBUTOR SYSTEM
%%
%%  Usage in .tex preamble:
%%    \addcontributor{Name}{Conceptualization, Methodology, Writing}
%%    \addreviewer{Name}{Senior Advocate, Supreme Court of India}
%%
%%  Renders on cover page below the abstract as two compact blocks:
%%    Contributors  (CRediT roles)
%%    Reviewers     (name + affiliation)
%%
%%  Both blocks are omitted entirely if no entries are added.
%% ============================================================

\newcounter{isrl@contrcount}
\setcounter{isrl@contrcount}{0}
\newcounter{isrl@reviewcount}
\setcounter{isrl@reviewcount}{0}

\newcommand{\addcontributor}[2]{%
  \stepcounter{isrl@contrcount}%
  \expandafter\def\csname isrl@cname@\theisrl@contrcount\endcsname{#1}%
  \expandafter\def\csname isrl@crole@\theisrl@contrcount\endcsname{#2}%
}

\newcommand{\addreviewer}[2]{%
  \stepcounter{isrl@reviewcount}%
  \expandafter\def\csname isrl@rname@\theisrl@reviewcount\endcsname{#1}%
  \expandafter\def\csname isrl@raffil@\theisrl@reviewcount\endcsname{#2}%
}

%% Internal: render contributor block
\newcommand{\isrl@rendercontributors}{%
  \ifnum\value{isrl@contrcount}>0
    {\footnotesize\color{FolioGray}\textsc{Contributors}\par}%
    \vspace{3mm}%
    \@tempcnta=1\relax
    \loop\ifnum\@tempcnta>\value{isrl@contrcount}\else
      {\footnotesize\color{InkColor}%
        \textbf{\csname isrl@cname@\the\@tempcnta\endcsname}\enspace
        \csname isrl@crole@\the\@tempcnta\endcsname\par}%
      \vspace{2pt}%
      \advance\@tempcnta\@ne
    \repeat
    \vspace{4mm}%
  \fi
}

%% Internal: render reviewer block
\newcommand{\isrl@renderreviewers}{%
  \ifnum\value{isrl@reviewcount}>0
    {\footnotesize\color{FolioGray}\textsc{Reviewed by}\par}%
    \vspace{3mm}%
    \@tempcnta=1\relax
    \loop\ifnum\@tempcnta>\value{isrl@reviewcount}\else
      {\footnotesize\color{InkColor}%
        \textbf{\csname isrl@rname@\the\@tempcnta\endcsname}%
        \ifx\csname isrl@raffil@\the\@tempcnta\endcsname\@empty\else
          ,\enspace\csname isrl@raffil@\the\@tempcnta\endcsname%
        \fi\par}%
      \vspace{1pt}%
      \advance\@tempcnta\@ne
    \repeat
  \fi
}

%% ============================================================
%%  METADATA COMMANDS
%% ============================================================

\newcommand{\subtitle}[1]{\def\@subtitle{#1}}
\newcommand{\docid}[1]{\def\@docid{#1}}
\newcommand{\department}[1]{\def\@department{#1}}
\newcommand{\license}[1]{\def\@license{#1}}
%% \coverabstract still accepted for backward compatibility but
%% does nothing — abstract now lives on page 1 via \makeabstractpage
\newcommand{\coverabstract}[1]{}
%% Optional second logo for collaborating lab
\newcommand{\collablogo}[1]{\def\@collablogo{#1}}

\def\@subtitle{}
\def\@docid{}
\def\@department{Interdisciplinary Systems Research Lab (iSRL)}
\def\@license{Licensed under CC BY 4.0}
\def\@collablogo{}

%% ============================================================
%%  LOGO BAR
%%  Single logo: iSRL left, rule fills the rest.
%%  Two logos:   iSRL left, collab right, rule between them.
%% ============================================================

\newcommand{\isrllogobar}{%
  \noindent
  \ifthenelse{\equal{\@collablogo}{}}{%
    %% — single logo mode —
    \begin{minipage}[b]{0.26\linewidth}%
      \IfFileExists{isrl-logo-landscape.png}{%
        \includegraphics[height=28pt]{isrl-logo-landscape.png}%
      }{\IfFileExists{../../assets/isrl-logo-landscape.png}{%
        \includegraphics[height=28pt]{../../assets/isrl-logo-landscape.png}%
      }{{\fontsize{20}{20}\selectfont\textit{i}\textsc{SRL}}}}%
    \end{minipage}%
    \hspace{3mm}%
    \begin{minipage}[b]{\dimexpr\linewidth-0.26\linewidth-3mm\relax}%
      {\color{InkColor}\rule{\linewidth}{0.55pt}}%
    \end{minipage}%
  }{%
    %% — two logo mode —
    \begin{minipage}[b]{0.26\linewidth}%
      \IfFileExists{isrl-logo-landscape.png}{%
        \includegraphics[height=28pt]{isrl-logo-landscape.png}%
      }{\IfFileExists{../../assets/isrl-logo-landscape.png}{%
        \includegraphics[height=28pt]{../../assets/isrl-logo-landscape.png}%
      }{{\fontsize{20}{20}\selectfont\textit{i}\textsc{SRL}}}}%
    \end{minipage}%
    \hspace{3mm}%
    \begin{minipage}[b]{\dimexpr\linewidth-0.26\linewidth-0.20\linewidth-6mm\relax}%
      {\color{InkColor}\rule{\linewidth}{0.55pt}}%
    \end{minipage}%
    \hspace{3mm}%
    \begin{minipage}[b]{0.20\linewidth}%
      \raggedleft
      \IfFileExists{\@collablogo}{%
        \includegraphics[height=28pt]{\@collablogo}%
      }{}%
    \end{minipage}%
  }%
}

%% ============================================================
%%  COVER PAGE  (\maketitle)
%%
%%  Layout: two zones separated by \vfill
%%    UPPER ZONE: logo bar | doc-id · report type label · title · subtitle
%%                authors · affiliations · date
%%    LOWER ZONE: thin navy rule · contributors · reviewers · license
%%
%%  The cover is unnumbered. Page counter resets to 1 after it.
%%  Abstract lives on page 1 via \makeabstractpage, not here.
%% ============================================================

\renewcommand{\maketitle}{%
  \begin{titlepage}%
    \pagecolor{BgColor}\color{InkColor}\setlength{\parskip}{0pt}%
    \newgeometry{top=26mm, bottom=26mm, left=24mm, right=24mm}%
    \noindent\begin{minipage}[t][\textheight][t]{\linewidth}%
    \setlength{\parskip}{0pt}%

    %% ── UPPER ZONE ──────────────────────────────────────────
    %% Logo bar + doc-id on same baseline
    \noindent
    \begin{minipage}[b]{0.74\linewidth}\isrllogobar\end{minipage}%
    \hfill
    \begin{minipage}[b]{0.22\linewidth}
      \raggedleft
      \ifthenelse{\equal{\@docid}{}}{}{{\small\color{FolioGray}\@docid}}%
    \end{minipage}
    \vspace{14mm}

    {\small\color{FolioGray}\textsc{Research Report}}
    \vspace{10mm}

    \begin{minipage}{\linewidth}%
    \fontsize{24}{32}\selectfont\bfseries\color{InkColor}\raggedright\@title%
    \end{minipage}\par
        \vspace{8mm}

    \ifthenelse{\equal{\@subtitle}{}}{}{%
      {\fontsize{13}{20}\selectfont\itshape\color{InkColor}\@subtitle\par}%
      \vspace{10mm}}

    \vspace{4mm}
\ifnum\value{isrl@authorcount}>0
  {\footnotesize\color{FolioGray}\textsc{Authors}\par}%
  \vspace{3mm}%
  \@tempcnta=1\relax
  \loop\ifnum\@tempcnta>\value{isrl@authorcount}\else
    {\footnotesize\color{InkColor}%
      \textbf{\csname isrl@name@\the\@tempcnta\endcsname}\enspace
      {\color{FolioGray}\csname isrl@affil@\the\@tempcnta\endcsname}\par}%
    \vspace{2pt}%
    \advance\@tempcnta\@ne
  \repeat
  \vspace{4mm}%
\else
  {\footnotesize\color{InkColor}\@author\par}%
\fi
    \vspace{5mm}
    {\small\color{FolioGray}\@date\par}

    %% Breathing room between upper and lower zones
    \vfill

    %% ── LOWER ZONE ──────────────────────────────────────────
    %% Contributors + reviewers only render if entries were added
    \isrl@rendercontributors
    \isrl@renderreviewers
    \vspace{8mm}
    {\color{NavyColor}\rule{\linewidth}{0.3pt}}\par%
    \vspace{5mm}
    \noindent{\footnotesize\color{FolioGray}\@license}

    \end{minipage}%
  \end{titlepage}%
  \isrl@setbodygeometry
  \setcounter{page}{1}%
  \thispagestyle{plain}%
}

%% ============================================================
%%  abstractpage ENVIRONMENT
%%
%%  Renders page 1: abstract text followed by TOC.
%%  Must be used immediately after \maketitle.
%%  Ends with \clearpage so body starts fresh on page 2.
%%
%%  Usage:
%%    \begin{abstractpage}
%%    Indian packaged food labels do not share a common
%%    ingredient vocabulary...
%%    \end{abstractpage}
%% ============================================================

\newenvironment{abstractpage}{%
  \thispagestyle{plain}%
  \vspace*{\fill}%
  \begin{abstract}%
}{%
  \end{abstract}%
  \vspace*{\fill}%
  \clearpage%
  \tableofcontents%
  \clearpage%
}

%% ============================================================
%%  TABLE OF CONTENTS
%% ============================================================

\let\isrl@orig@toc\tableofcontents
\renewcommand{\tableofcontents}{%
  \ifisrl@sidenotes
    \begin{adjustwidth}{0pt}{-\isrl@right}%
      \isrl@orig@toc
    \end{adjustwidth}%
  \else
    \isrl@orig@toc
  \fi
}

%% ============================================================
%%  HEADER / FOOTER
%% ============================================================

\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{{\small\color{InkColor}Interdisciplinary Systems Research Lab (iSRL)}}
\fancyhead[R]{{\small\color{FolioGray}\thepage}}

\renewcommand{\headrulewidth}{0.3pt}
\renewcommand{\footrulewidth}{0pt}
\patchcmd{\headrule}{\hrule}{\color{NavyColor}\hrule}{}{}
\fancypagestyle{plain}{%
  \fancyhf{}%
  \renewcommand{\headrulewidth}{0pt}%
  \renewcommand{\footrulewidth}{0pt}%
}


%% ============================================================
%%  SECTION STYLES
%% ============================================================

\titlespacing*{\section}{0pt}{22pt plus 4pt minus 2pt}{9pt plus 2pt}

\titleformat{\subsection}
  {\normalsize\bfseries\color{InkColor}}{\thesubsection}{1em}{}
\titlespacing*{\subsection}{0pt}{15pt plus 3pt minus 2pt}{5pt plus 1pt}

\titleformat{\subsubsection}
  {\normalsize\itshape\color{InkColor}}{\thesubsubsection}{1em}{}
\titlespacing*{\subsubsection}{0pt}{11pt plus 2pt}{4pt}

%% ============================================================
%%  TOC STYLE
%% ============================================================

\renewcommand{\contentsname}{\normalfont\large\bfseries Contents}
\setlength{\cftbeforetoctitleskip}{0pt}
\setlength{\cftaftertoctitleskip}{10pt}
\renewcommand{\cftsecfont}{\normalsize\color{InkColor}}
\renewcommand{\cftsecpagefont}{\small\color{InkColor}}
\renewcommand{\cftsubsecfont}{\small\color{InkColor}}
\renewcommand{\cftsubsecpagefont}{\small\color{InkColor}}
\renewcommand{\cftdotsep}{5}
\renewcommand{\cftdot}{\textcolor{NavyColor}{.}}

%% ============================================================
%%  CAPTIONS
%% ============================================================

\captionsetup{
  font=small, labelfont={bf,color=NavyColor},
  labelsep=period, justification=raggedright, singlelinecheck=false,
}

%% ============================================================
%%  SIDENOTE STYLE
%% ============================================================

\setlength{\marginparwidth}{\isrl@mparwidth}
\setlength{\marginparsep}{\isrl@mparsep}

%% ============================================================
%%  REFERENCES ENVIRONMENT
%%
%%  Usage:
%%    \begin{references}
%%      \bibitem{key} Author. \textit{Title}. Details.
%%    \end{references}
%%
%%  \bibitem does two things:
%%    1. Renders the [N] label and list item visually
%%    2. Writes \bibstorenum{key}{N} to the .aux file so \cite
%%       can resolve on the next compile pass
%%
%%  Compile twice after any change to reference order or content.
%% ============================================================

\newcounter{isrl@bibcount}

\newenvironment{references}{%
  \clearpage
  \section*{References}%
  \addcontentsline{toc}{section}{References}%
  \setcounter{isrl@bibcount}{0}%
  \begin{list}{}{%
    \setlength{\labelwidth}{2em}%
    \setlength{\labelsep}{0.5em}%
    \setlength{\leftmargin}{2.5em}%
    \setlength{\itemindent}{0pt}%
    \setlength{\itemsep}{6pt}%
    \setlength{\parsep}{0pt}%
  }%
}{%
  \end{list}%
  \ifisrl@sidenotes\end{adjustwidth}\fi
}

%% \bibitem{key} — numbered, hyperlink anchor, writes to .aux
\renewcommand{\bibitem}[2][]{%
  \stepcounter{isrl@bibcount}%
  \item[{[\theisrl@bibcount]}]%
  \ifthenelse{\equal{#2}{}}{}{%
    \phantomsection\label{bib:#2}%
    %% Store in current run's namespace (for \cite in same-pass body text)
    \expandafter\xdef\csname bib@num@#2\endcsname{\theisrl@bibcount}%
    %% Write to .aux so next compile resolves \cite in cover + early text
    \immediate\write\@auxout{%
      \string\bibstorenum{#2}{\theisrl@bibcount}%
    }%
  }%
}

%% ============================================================
%%  ABSTRACT ENVIRONMENT
%%  Unboxed. Label in small caps, text in small with generous
%%  leading. No border, no background change — just prose.
%% ============================================================

\renewenvironment{abstract}{%
  \noindent{\small\color{FolioGray}\textsc{Abstract}}\par%
  \vspace{5pt}%
  \small\color{InkColor}\setstretch{1.4}%
  \noindent\ignorespaces
}{\par}

%% ============================================================
%%  LISTS
%% ============================================================

\setlist{itemsep=4pt, topsep=5pt, partopsep=0pt, parsep=2pt}
\setlist[itemize]{leftmargin=1.6em}
\setlist[enumerate]{leftmargin=1.6em}

%% ============================================================
%%  MISCELLANEOUS
%% ============================================================

\widowpenalty=10000
\clubpenalty=10000
\raggedbottom

%% ============================================================
%%  END
%% ============================================================