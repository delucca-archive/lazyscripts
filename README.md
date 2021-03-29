<p align="center">
  <br>
   <img src="https://media.giphy.com/media/JstFYY8FwlBm48n7De/giphy.gif" alt="Jim (from The Office) napping" title="Execution Mode header's GIF" />
  <br>
</p>
<p align="center">
Multi-purpose shell scripts to automate routine tasks 
</p>

## 📖 About this

As any developer, I have a bunch of routine tasks that I need to do. Some of those are hard (like setup my workstation), others are boring (like reporting). This repository aims to create scripts to automate those tasks accordingly.

* [Table of contents][empty]
  * [Quickstart][section-quickstart]
  * [Usage][section-usage]
  * [License][section-license]

## 🧙‍♂️ Quickstart

Using this repository is as simple as executing any binary file inside the `bin` folder. For example, you can execute the `bootstrap-code-env` script with the following command:

```sh
./bin/bootstrap-code-env
```

## 👩‍🔬 Usage

Each script contains a `--help` argument. If you provide that argument while running the command, you can see brief documentation explaining what the script does and how to use it.

For example:
```sh
> ./bin/bootstrap-code-env --help
Bootstraps my code environment on the current machine by installing all required tools and dotfiles.

usage: ./src/commands/init-code-environment [OPTIONS]	 
 --help Show this message	 
 --minimal Install only the minimal required tools	 
 --shell-tools Install my shell tools	 
 --dev-tools Install my dev tools	 
 --dotfiles Install my dotfiles	 
 --complete Install my shell tools, dev tools and dotfiles at once
```

## 🔓 License

Distributed under the Apache 2.0 License. See [`LICENSE`][file-license] for more information.

[comment]: <> (Link references)
[comment]: <> (----------------------------------------------------------------------------------------)
[empty]: # "An empty link"
[section-quickstart]: #-quickstart "Go to Quickstart section"
[section-usage]: #-usage "Go to Usage section"
[section-license]: #-license "Go to License section"
[file-contributing]: CONTRIBUTING.md "Open CONTRIBUTING.md file"
[file-license]: LICENSE "Open LICENSE file"