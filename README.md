Tool to generate verilator testbench

## Use

### External dependencies

libboost_program_options1_66_0-devel

### Generate testbench files

```sh
./burbulator gen --project project.json --output <destination folder>
```

### Generate data files (MIF)

```sh
./burbulator mif --project project.json --output <destination folder>
```

## Tool Build

Install nodejs 6 using `nvm` https://github.com/creationix/nvm

```sh
nvm i 6
```

```sh
npm i
npm run build
```
