# bachelor-thesis-cacao-jvm

This is my bachelor thesis for [BSc Software and Information Engineering](https://informatics.tuwien.ac.at/bachelor/software-and-information-engineering/) at the TU Wien.

PDF: [CACAO OSR](./cacao-osr.pdf) (draft version, work in progress)

## Cacao JVM

Bitbucket: https://bitbucket.org/cacaovm/cacao/

Homepage: www.cacaojvm.org

Coding conventions: http://c1.complang.tuwien.ac.at/cacaowiki/Draft/CodingConventions

## Latex template

https://informatics.tuwien.ac.at/study-services/master-graduation/

To generate the class I did the following:

- copy https://gitlab.com/ThomasAUZINGER/vutinfth to `./vutinfth`
- `cd vutinfth && sh build-all.sh`
- use https://www.diffchecker.com/pdf-diff/ 
 to compare `example.pdf` with `example-ref.pdf` 
  - some parts were slightly different

My latex code is in `./thesis`.

# Development

I used `dev/dev.sh` to develop inside a docker container.

An overview on my development environment can be found in [development.md](development.md).
