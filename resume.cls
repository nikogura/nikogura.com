\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{resume}[2025/12/05 Resume Class]

% Base class
\LoadClass[11pt,letterpaper]{article}

% Required packages
\RequirePackage[
    top=0.5in,
    bottom=0.5in,
    left=0.5in,
    right=0.5in
]{geometry}

% Input encoding for Unicode support (pdflatex compatible)
\RequirePackage[utf8]{inputenc}
\RequirePackage[T1]{fontenc}

% Sans-serif font as default (Helvetica)
\RequirePackage{helvet}
\renewcommand{\familydefault}{\sfdefault}

% Remove page numbers
\pagestyle{empty}

% Useful packages for resumes
\RequirePackage{enumitem}
\RequirePackage{titlesec}
\RequirePackage{hyperref}
\RequirePackage{amssymb}  % For checkbox symbols

% Code highlighting support (for pandoc Shaded environment)
\RequirePackage{fancyvrb}
\RequirePackage{framed}
\RequirePackage{xcolor}

% Define Shaded environment for code blocks
\definecolor{shadecolor}{RGB}{248,248,248}
\newenvironment{Shaded}{\begin{snugshade}}{\end{snugshade}}

% Define Highlighting environment (used within Shaded)
\DefineVerbatimEnvironment{Highlighting}{Verbatim}{commandchars=\\\{\},fontsize=\small}
\newcommand{\AlertTok}[1]{\textcolor[rgb]{1.00,0.00,0.00}{\textbf{#1}}}
\newcommand{\AnnotationTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}
\newcommand{\AttributeTok}[1]{\textcolor[rgb]{0.49,0.56,0.71}{#1}}
\newcommand{\BaseNTok}[1]{\textcolor[rgb]{0.25,0.63,0.44}{#1}}
\newcommand{\BuiltInTok}[1]{#1}
\newcommand{\CharTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\CommentTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textit{#1}}}
\newcommand{\CommentVarTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}
\newcommand{\ConstantTok}[1]{\textcolor[rgb]{0.53,0.00,0.00}{#1}}
\newcommand{\ControlFlowTok}[1]{\textcolor[rgb]{0.00,0.44,0.13}{\textbf{#1}}}
\newcommand{\DataTypeTok}[1]{\textcolor[rgb]{0.56,0.13,0.00}{#1}}
\newcommand{\DecValTok}[1]{\textcolor[rgb]{0.25,0.63,0.44}{#1}}
\newcommand{\DocumentationTok}[1]{\textcolor[rgb]{0.73,0.13,0.13}{\textit{#1}}}
\newcommand{\ErrorTok}[1]{\textcolor[rgb]{1.00,0.00,0.00}{\textbf{#1}}}
\newcommand{\ExtensionTok}[1]{#1}
\newcommand{\FloatTok}[1]{\textcolor[rgb]{0.25,0.63,0.44}{#1}}
\newcommand{\FunctionTok}[1]{\textcolor[rgb]{0.02,0.16,0.49}{#1}}
\newcommand{\ImportTok}[1]{#1}
\newcommand{\InformationTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}
\newcommand{\KeywordTok}[1]{\textcolor[rgb]{0.00,0.44,0.13}{\textbf{#1}}}
\newcommand{\NormalTok}[1]{#1}
\newcommand{\OperatorTok}[1]{\textcolor[rgb]{0.40,0.40,0.40}{#1}}
\newcommand{\OtherTok}[1]{\textcolor[rgb]{0.00,0.44,0.13}{#1}}
\newcommand{\PreprocessorTok}[1]{\textcolor[rgb]{0.74,0.48,0.00}{#1}}
\newcommand{\RegionMarkerTok}[1]{#1}
\newcommand{\SpecialCharTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\SpecialStringTok}[1]{\textcolor[rgb]{0.73,0.40,0.53}{#1}}
\newcommand{\StringTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\VariableTok}[1]{\textcolor[rgb]{0.10,0.09,0.49}{#1}}
\newcommand{\VerbatimStringTok}[1]{\textcolor[rgb]{0.25,0.44,0.63}{#1}}
\newcommand{\WarningTok}[1]{\textcolor[rgb]{0.38,0.63,0.69}{\textbf{\textit{#1}}}}

% Hyperlink styling
\hypersetup{
    colorlinks=true,
    linkcolor=black,
    urlcolor=blue,
    pdfborder={0 0 0}
}

% Tighter spacing for lists
\setlist{nosep, leftmargin=1.5em}

% Pandoc tightlist command
\providecommand{\tightlist}{%
  \setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}

% Section formatting - compact and sans-serif (no numbering)
\titleformat{\section}
    {\large\bfseries\sffamily}
    {}
    {0em}
    {}
    [\titlerule]

\titlespacing{\section}{0pt}{6pt}{3pt}

% Remove section numbering
\setcounter{secnumdepth}{0}

% Subsection formatting
\titleformat{\subsection}
    {\normalsize\bfseries\sffamily}
    {}
    {0em}
    {}

\titlespacing{\subsection}{0pt}{4pt}{2pt}

% Reduce paragraph spacing
\setlength{\parindent}{0pt}
\setlength{\parskip}{4pt}
