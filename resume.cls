\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{compactresume}[2025/12/02 Compact Resume Class]

% Base class
\LoadClass[11pt,letterpaper]{article}

% Required packages
\RequirePackage[
    top=0.5in,
    bottom=0.5in,
    left=0.5in,
    right=0.5in
]{geometry}

% Sans-serif font as default
\RequirePackage{helvet}
\renewcommand{\familydefault}{\sfdefault}

% Optional: Better sans-serif fonts (uncomment if available)
% \RequirePackage{tgheros}  % TeX Gyre Heros (Helvetica alternative)
% \RequirePackage{opensans} % Open Sans

% Remove page numbers
\pagestyle{empty}

% Useful packages for resumes
\RequirePackage{enumitem}
\RequirePackage{titlesec}
\RequirePackage{hyperref}

% Hyperlink styling
\hypersetup{
    colorlinks=true,
    linkcolor=black,
    urlcolor=blue,
    pdfborder={0 0 0}
}

% Tighter spacing for lists
\setlist{nosep, leftmargin=1.5em}

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
