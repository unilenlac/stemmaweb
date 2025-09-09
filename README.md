
Stemmaweb - a Catalyst web interface for text tradition analysis
=============================================================


Stemmaweb is a web interface for analyzing variations between different manuscript versions of the same text. The interface also allows to import traditions and export critical text editions. It is built using the Catalyst framework in Perl and utilizes JQuery for the frontend.

This version of Stemmaweb is a fork of the original project, with additional features and improvements.

This fork is maintained by the [IRSB](https://github.com/unilenlac/stemmaweb) (Institut Romand des Sciences Bibliques) of the [University of Lausanne](https://www.unil.ch/).

### The Stemmaweb environment

Originally the Stemmaweb frontend has been built to work with the [Stemmarest](https://github.com/unilenlac/tradition_repo) backend, which provides a RESTful API for accessing and manipulating text traditions.

If you need a script to collate texts and import them into the stemmarest backend, you can use this [collate and import script](https://github.com/unilenlac/enlac). Please note that this script handles only XML texts that follows the [ENLAC DTD](https://github.com/unilenlac/martyre-philippe/blob/PM-1_master/tei-irsb.dtd) specification, but can be modified to suit your needs.


### Installation 
------------

This web interface use the [Perl](https://www.perl.org/) language and the [Catalyst framework](https://metacpan.org/dist/Catalyst-Manual/view/lib/Catalyst/Manual/Tutorial.pod).

Both technologies are old, and setting them up locally can be challenging. We highly recommend to use a local container to deploy and use the app locally. If you don't want to use Docker, please find below the original installation procedure.

***

To run Stemmaweb you need a working Perl installation (5.12 or above)
and, preferably, a working webserver. The following steps will get you
set up to run the standalone service:

* Ensure that the following software is installed (the list given is that of the relevant Ubuntu packages):
  * gcc
  * make
  * libxml2-dev
  * zlib1g-dev
  * libexpat1-dev
  * graphviz
  * libssl-dev
  * libgmp-dev
* Install the following Perl modules:
  * App::cpanminus
  * Module::Install::Catalyst
* Install the dependencies for Stemmaweb from this directory: 

		cd /PATH/TO/stemmaweb && cpanm -S --installdeps .
* Make a test database (which relies on SQLite being installed) and test the installation at http://localhost:3000/ :

		script/maketestdb.pl
		script/stemmaweb_server.pl
* If you only want to test Stemmaweb, then you are done! Otherwise, create a database for the storage of text tradition data. This can be anything supported by Perl's DBI, so long as you have the database software and relevant DBD::* drivers installed.
* Replace the database settings in stemmaweb.conf with the settings for your database. If you are using MySQL, for example, the contents of the <Model Directory> stanza might look like this:

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
		
* (Optionally) configure Stemmaweb to run under FastCGI, Starman, or any other Catalyst-compatible application framework. See http://www.catalystframework.org for more information. The provided stemmaweb.psgi was written to work with Starman running behind Apache on a specified non-root URL path.

### Run Stemmaweb with Docker
----------

Stemmaweb can be run inside a Docker container. A Dockerfile is included in the repository. If you need to customize the Docker setup, you can modify the Dockerfile as needed.

To run the docker container, use the following command:

```bash
docker build -t stemmaweb:ubuntu-18.04 .
docker run -p 3000:3000 stemmaweb:ubuntu-18.04
```

You don't necesseraly need to add Stemmaweb to a Docker network to make it work with Stemmarest, but it is recommended to, specially if you are using Docker.

Debugging is possible by using the -d option when running the Docker by editing CMD statement.

```bash
perl -d script/stemmaweb_server.pl
```

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