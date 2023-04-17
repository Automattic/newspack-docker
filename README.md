# newspack-docker
Newspack helper Repository for running local environments using Docker.

The main idea is to have all the dependecies we need to run the projects, and its tests, inside the container so we don't depend on anything in our local machine.
## Getting started

### Clone this repository

```BASH
git clone https://github.com/Automattic/newspack-docker.git
```

### Set up your local vars

Make a copy of `default.env` to `.env`

```BASH
cp default.env .env
```

Edit the file and choose your own variables

You can change the password and username of your WordPress user.

Linux users might want to configure apache to run as the same user as the host machine. You can do that in this file

### Build the Docker image

You only need to run this the first time you set up your env.

```BASH
./build-image.sh
```

The default builds using PHP 8.1. You can also call `./build-image-7.4.sh` or `./build-image-8.sh` to build an image with PHP 7.4 or 8.0. It's a good idea to have both.

### Clone all repos

This will clone all Newspack repos inside the `repos` folder

```BASH
./clone-repos.sh
```

### Lauch the container and install WordPress

Now we are going to use the `n` script. (Tip: Create an alias in your `.bashrc` so you can call it from anywhere)

#### Launch the container
```BASH
n start
```

(`n start 8` or `n start 7.4` will start the image with php 8.0 or 7.4 if you built them)

When you are done, you can stop the containers with `n stop`.

At this point you should be able to see your site in `http://localhost`.

#### Install WordPress
```BASH
n install
```

#### Build the projects

The first time you set up your environment you might want to build all the projects. You can do this by:

```BASH
n build all
```

## The N script

The `n` script will help you perform actions inside the containers. Some examples:

Build one specific project:

```BASH
n build theme # Builds the newspack-theme repo
n build newspack-plugin # Builds the main plugin
n build newsletters # You can also omit the 'newspack-' prefix from plugins
```

Watch and run tests on projects:

These commands will automatically run in the repo folder you are currently in

```BASH
n watch # Runs npm watch on the project you are currently in
n test-php # Runs phpunit tests on the project you are currently in
n test-js # Runs js tests on the project you are currently in
```

Run composer commands inside one of the projects

```BASH
n composer dump-autoload # Runs `composer dump-autload` inside the current repo
n composer update # Runs `composer update` inside the current repo
```

Run WP CLI interactive shell

```BASH
n shell
```

Enter the container bash

```BASH
n sh # as the apache user, if USE_CUSTOM_APACHE_USER was set in your .env
n rsh # as root
```

Other commands:

* `n db`: Launches the MySQL interactive shell
* `n wp`: runs any arbitraty WP CLI command. e.g. `n wp option get blogname`
* `n tail`: Tails the apache error log file
* `n uninstall`: Uninstalls WordPress
* `jncp`, `jninit` & `secrets`: See Jurassic Ninja section below.
* `n secrets-import`: Import all your secrets from a `secrets.json` file (see details on the Jurassic Ninha section below)
* `n snapshot $name`: Creates a snapshot of the current site and gives it a name
* `n snapshot-load $name`: Drops the current site and override it with the data from a snapshot
* `n new-site`: Drops the current site and creates a new one from scratch
* `n pull`: Pull every git repository inside `repos/`

## Jurassic Ninja

There are some commands to help you work with Jurassic Ninja

### Initialize and Sets up a new JN Site
```BASH
n jninit user domain.jurassic.ninja
```

This command Sets up a new Jurassic Ninja site. It will
* Upload the newspack-plugin from your machine to JN
* Run `wp newspack setup`
* Copy your secrets to the JN site

**Setting up your Secrets**

If you want your secrets to be copied over to the JN site, create a `secrets.json` file inside the `bin` folder.

You can copy the `secrets.json.sample` file and manually edit it, or you can use `n secrets` to output the secrets you currently have on your local site.

If you want to directly copy the secrets into the file you can run `n secrets > bin/secrets.json`.

### Copy plugins to a JN Site
```BASH
n jncp user domain.jurassic.ninja
```

This command will allow you to copy one or many plugins from your local env to the JN site at once.

This is useful if you want to replace the plugin in the site with the custom branch you have checked out, or if you want to upload any other plugin you have.

## Mailhog

Mailhog is running by default so you can see all the emails that are sent from your WordPress site.

Visit http://localhost:8025 to see it.

## Adminer

Adminer is available at http://localhost:8088

Connect to Server `db`, user `root` and password defined in your local `.env` file.

## Memcached

By default, Memcached plugin is enabled. If you want to disable it, simply delete the `html/wp-content/object-cache.php` file.

## Newspack Manager

This Docker environment will launch two sites by default. One is the site you will be working on to develop all plugins, and the other is the one that will run the Newspack Manager Client.

In order to be able to access the Newspack Manager site, there are a few additional steps:

Setup the manager by installing WordPress, creating the key pairs, adding the constants to both sites and activate the plugins. All this is done by:
```BASH
n setup-manager
```

Configure the `manager.local` domain to point to your localhost by adding it to the `hosts` file.

In your favorite text editor, open the `/etc/hosts` file and add a line with `127.0.0.1 manager.local`. Or run the following command:
```BASH
echo "127.0.0.1 manager.local" | sudo tee -a /etc/hosts
```

If you haven't done it yet, build the Manager Client plugin:
```BASH
n build manager-client
```
(Note that you can also use `watch` here while developing)

That's it!

Now visit `manager.local/wp-admin`, go to Newspack Manager, and add the URL for you other site there.

### Note about the site domain when running CLI commands

By default, the docker environment provides a dynamic site url, so you can access the site either via localhost or a tunneled domain, required for some actions. This is useful because it allows you to run your site without the tunnel when you don't need it.

Because of that, when running commands via CLI, the returned site url is localhost. This will create issues when communicating with the manager, as the keys are tied to the site domain.

Use the NEWSPACK_DOCKER_SITE_URL_CLI_OVERRIDE to override the site url for CLI commands.

In your dev site (not the manager.local instance), add the following
```
define( 'NEWSPACK_DOCKER_SITE_URL_CLI_OVERRIDE', 'https://my-domain.my-tunnel.com' );
```