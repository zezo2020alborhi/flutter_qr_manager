# Why Flutter uses `lib` instead of `src`

This directory is included only to make the project layout clear for developers familiar with React or ASP.NET conventions. Flutter applications use `lib/` as the standard source root, not `src/`.

The executable Flutter entry point is `../lib/main.dart`. All application source code is in `../lib/`, including screens, models, controllers, services, theme, and widgets. Do not move files into this directory; Flutter tooling resolves package source from `lib/`.
