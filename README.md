
Stemmaweb - a Catalyst web interface for text tradition analysis
=============================================================


Stemmaweb is a web interface for analyzing variations between different manuscript versions of the same text. The interface also allows to import traditions and export critical text editions. It is built using the Catalyst framework in Perl and utilizes JQuery for the frontend.

This version of Stemmaweb is a fork of the original project, with additional features and improvements.

This fork is maintained by the [IRSB](https://github.com/unilenlac/stemmaweb) (Institut Romand des Sciences Bibliques) of the [University of Lausanne](https://www.unil.ch/).

### The Stemmaweb environment

Originally the Stemmaweb frontend has been built to work with the [Stemmarest](https://github.com/unilenlac/tradition_repo) backend, which provides a RESTful API for accessing and manipulating text traditions.

If you need a script to collate texts and import them into the stemmarest backend, you can use this [collate and import script](https://github.com/unilenlac/enlac). Please note that this script handles only XML texts that follows the [ENLAC DTD](https://github.com/unilenlac/martyre-philippe/blob/PM-1_master/tei-irsb.dtd) specification, but can be modified to suit your needs.


### Installation & Quick Start
------------

This web interface uses the [Perl](https://www.perl.org/) language and the [Catalyst framework](https://metacpan.org/dist/Catalyst-Manual/view/lib/Catalyst/Manual/Tutorial.pod). 


***

#### 1: Run with Docker 

Stemmaweb is containerized and ready to deploy.

1. **Build the image**:
   ```bash
   docker build -t stemmaweb:ubuntu-18.04 .
   ```

2. **Run the container** (requires passing the configuration environment variables):
   ```bash
   docker run -e SBRIDGE_URL="http://your-sbridge-host:sbridge_port" \
              -e STEMMAREST_URL="http://your-stemmarest-host:port" \
              -e USER="StemmaWeb-user" \
              -e PASS="StemmaWeb-password" \
              -p 3000:3000 stemmaweb:ubuntu-18.04
   ```

Optional: **Run for local development** (mounts your current directory for hot reloading when files change):
   ```bash
   docker run -it --rm \
     -p 3000:3000 \
     -v $PWD:/stemmaweb \
     -e SBRIDGE_URL="http://your-sbridge-host:sbridge_port" \
      -e STEMMAREST_URL="http://your-stemmarest-host:port" \
      -e USER="StemmaWeb-user" \
      -e PASS="StemmaWeb-password" \
     stemmaweb:ubuntu-18.04 \
     perl script/stemmaweb_server.pl -r
   ```

> [!NOTE]
> Connecting Stemmaweb to a Docker network is recommended to easily communicate with your backend database or Stemmarest container.
> Debugging inside the container is possible by using the `-d` option when running the perl test server (e.g. `perl -d script/stemmaweb_server.pl`).


## Configuration

Stemmaweb needs to be configured to connect to the Stemmarest backend and the s-bridge module.

> [!WARNING]
> Since the `__ENV` macro requires the environment variables to exist, you **must always pass `SBRIDGE_URL`, `STEMMAREST_URL`, `USER`, and `PASS` at runtime** (e.g. via `docker run -e SBRIDGE_URL=... -e STEMMAREST_URL=... -e USER=... -e PASS=...`), or the application will fail to start.

### Usage guide
--------

A small usage guide can be found in the interface. In this section we show very briefly how to use the exporation feature :

After having finished your critical edition, exportation can be done by :

- Go to the home page and sign-in.
- Select the tradition you need to export on the left selection panel.
- Click the "Download tradition" button on the right side of the interface.
- Select the XML exportation format.
- Select the section range you want to export.
- Click the "Download" button to download the file.

Exportation errors are displayed in the download window. A more detailed error log can be be downloaded if a link is provided with the error message.

You can also export the critical text of a section.

- select a tradition with the 'view collation and edit relationships' button.
- select a section eventually.
- find the "Download section" button on the top part of the interface.
- Select the XML exportation format.
- When the document is ready, the XML file will be available for download.

Please note that the downloaded files are XML files that conform to the TEI (Text Encoding Initiative) guidelines.

### Changelog
------------

- Add ui components and logic to handle hypernodes creation and management.
- Add ui component and logic to use tradition/section critical text.
exportation feature from [Stemmarest](https://github.com/unilenlac/tradition_repo)
- Improve lots of ui feature (pan, zoom, shortcut, etc).
- Optimize Dockerfile.
