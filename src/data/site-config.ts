import avatar from '../assets/images/avatar.png';
import type { SiteConfig } from '../types';

const siteConfig: SiteConfig = {
    website: 'https://nikogura.com',
    avatar: {
        src: avatar,
        alt: 'Nik Ogura'
    },
    title: 'Nik Ogura',
    subtitle: 'Distinguished Engineer & Infrastructure Architect',
    description:
        'Platform engineering, security, infrastructure, and the occasional philosophical tangent. Writing about Kubernetes, observability, GitOps, and building things that work.',
    headerNavLinks: [
        {
            text: 'Home',
            href: '/'
        },
        {
            text: 'Projects',
            href: '/projects'
        },
        {
            text: 'Blog',
            href: '/blog'
        },
        {
            text: 'Tags',
            href: '/tags'
        }
    ],
    footerNavLinks: [
        {
            text: 'About',
            href: '/about'
        },
        {
            text: 'Resume',
            href: '/resume'
        },
        {
            text: 'KATN Solutions',
            href: 'https://katn-solutions.io'
        }
    ],
    socialLinks: [
        {
            text: 'GitHub',
            href: 'https://github.com/nikogura'
        },
        {
            text: 'LinkedIn',
            href: 'https://www.linkedin.com/in/nikogura'
        }
    ],
    hero: {
        title: 'Viam inveniam, aut faciam.',
        text: "*(I'll find a way, or I'll make one.)*\n\nI'm **Nik Ogura** — distinguished engineer, infrastructure architect, and security practitioner.\nI build platforms, tools, and systems that work superlatively. I've spent my career making Kubernetes, observability, and security infrastructure that teams actually want to use.\n\nCurrently I run [KATN Solutions](https://katn-solutions.io), helping companies build enterprise-grade infrastructure their teams can own.\n\nThis site is where I write about the things I've learned, the tools I've built, and the opinions I've formed along the way. Browse my [open source projects](/projects) or read my [writing](/blog).",
        actions: [
            {
                text: 'About Me',
                href: '/about'
            }
        ]
    },
    subscribe: {
        enabled: false
    },
    postsPerPage: 8,
    projectsPerPage: 8
};

export default siteConfig;
