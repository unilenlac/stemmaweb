
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

Because Perl/Catalyst can be challenging to configure locally, we **highly recommend running Stemmaweb inside a Docker container**. 

***

#### Option 1: Run with Docker (Recommended)

Stemmaweb is containerized and ready to deploy.

1. **Build the image**:
   ```bash
   docker build -t stemmaweb:ubuntu-18.04 .
   ```

2. **Run the container** (requires passing the `SBRIDGE_URL` environment variable parameter):
   ```bash
   docker run -e SBRIDGE_URL="http://your-sbridge-host:sbridge_port" -p 3000:3000 stemmaweb:ubuntu-18.04
   ```

Optional: **Run for local development** (mounts your current directory for hot reloading when files change):
   ```bash
   docker run -it --rm \
     -p 3000:3000 \
     -v $PWD:/stemmaweb \
     -e SBRIDGE_URL="http://your-sbridge-host:sbridge_port" \
     stemmaweb:ubuntu-18.04 \
     perl script/stemmaweb_server.pl -r
   ```

> [!NOTE]
> Connecting Stemmaweb to a Docker network is recommended to easily communicate with your backend database or Stemmarest container.
> Debugging inside the container is possible by using the `-d` option when running the perl test server (e.g. `perl -d script/stemmaweb_server.pl`).

***

#### Option 2: Native Perl Installation (Alternative)

If you do not want to use Docker, follow this procedure to set up a native installation:

To run Stemmaweb you need a working Perl installation (5.12 or above) and a webserver.

1. **Install system packages** (example Ubuntu packages list):
   * `gcc`, `make`, `libxml2-dev`, `zlib1g-dev`, `libexpat1-dev`, `graphviz`, `libssl-dev`, `libgmp-dev`
2. **Install core Perl package management tools**:
   ```bash
   cpan -T App::cpanminus
   cpanm -n Module::Install::Catalyst
   ```
3. **Install application dependencies**:
   ```bash
   cd /PATH/TO/stemmaweb && cpanm -S --installdeps .
   ```
4. **Initialize a local SQLite test database and run the server**:
   ```bash
   script/maketestdb.pl
   script/stemmaweb_server.pl
   ```
   You can now test the installation at `http://localhost:3000/`.

5. **Production Databases**: For storage of real text tradition data, replace the SQLite settings in `stemmaweb.conf` with your database of choice (e.g., MySQL, PostgreSQL) and install the relevant Perl `DBD::*` driver.
   For example, a MySQL database configuration stanza in `<Model Directory>` would look like this:
   ```
   <model_args>
   dsn dbi:mysql:dbname=stemmaweb;host=DB_HOSTNAME
   <extra_args>
       user STEMMAWEB_USER
       password STEMMAWEB_PASS
       <dbi_attrs>
           mysql_enable_utf8 1
       </dbi_attrs>
   </extra_args>
   </model_args>
   ```

6. **Production Deployment**: You can configure Stemmaweb to run under FastCGI, Starman, or any other Catalyst-compatible application framework (see the Catalyst documentation). The provided `stemmaweb.psgi` is configured to run behind Apache on a specified non-root URL path.

Debugging screen is then available, for instance, if the container is running is not running on the background:

```bash
docker run -it --rm --name stemmaweb --network stemmaweb -p 3000:3000 stemmaweb:ubuntu-18.04
````

## Configuration

Stemmaweb needs to be configured to connect to the Stemmarest backend. This typically involves setting the API endpoint URL.

The API endpoint can be set in the Stemmaweb configuration file (e.g., `stemmaweb.conf`) under the `[tradition_repo]` variable:

```
<Model Directory>
	tradition_repo http://my-server:8080/stemmarest/api
</Model Directory>
````

Stemmaweb also needs to be configured to connect to the s-bridge module. This involves setting the API endpoint URL in the Stemmaweb configuration file `stemmaweb.conf`:

You must use the `__ENV(VAR_NAME)__` macro to load values from environment variables at runtime, which is useful when deploying the Docker container:

```
<Component Controller::Sbridge>
    sbridge_url __ENV(SBRIDGE_URL)__
</Component>
```

> [!WARNING]
> Since the `__ENV` macro requires the environment variable to exist, you **must always pass `SBRIDGE_URL` at runtime** (e.g. via `docker run -e SBRIDGE_URL=...`), or the application will fail to start.

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
