# nvm
Node Version Manager in Bash script. This script doen't need root access for npm or node because they are both installed in ~/.nvm and all it's binaries and packages. Inspired by [n](https://github.com/tj/n/).

### Requirements
This script requires the following programs to work:
 - wget
 - sudo

### Instalation
Clone this repo, enter in the cloned directory and execute:

```shell
./install.sh
```
This script requires root access to create symbolic links to /usr/local/bin and /usr/bin. Thats it.

### Usage
Execute the help command to see the available commands:

```shell
nvm help
```

## Commands
The available commands are:
 - install <version>
 - use <version> --npm
 - remove <version>
 - list
 - help

### Goals
- [ ] List all available versions
- [ ] Work for 32 or 64 Linux Archtectures

### License
(The MIT License)

Copyright (c) 2016 Marco Túlio Ávila Santos <marcotulio.avila@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
