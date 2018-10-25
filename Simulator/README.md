# Projet PGCS (HUG)

## Langage de programmation

L'application PGCS est programmée intégralement en JavaScript (norme ECMAScript Edition 6).

## Dépendences

### Node.js

L'environnement d'exécution JavaScript `Node.js` est obligatoire. C'est cet environnement qui est utilisé pour créer l'application web sur http://pgcs.unige.ch
Une installation guidée pour `Node.js` est disponible [ici](https://nodesource.com/blog/installing-nodejs-tutorial-windows/).

### yarn

Le gestionnaire de paquets `yarn`est utilisé plutôt que `npm`. L'avantage de ce premier est avant tout d'améliorer la gestion des dépendances. Plus de détails dans la comparaison de ces deux systèmes [ici](https://www.sitepoint.com/yarn-vs-npm/).

Pour installer `yarn` il suffit de taper la commande suivante :

```bash
npm i -g yarn
```

## Installation 

Le script suivant permet de télécharger le code source de pgcs, d'installer les dépendances nécessaires et de lancer le programme. A l'exécutation de la commande `yarn start`, une page du fureteur doit s'ouvrir et pointer sur l'adresse `http://localhost:3001`.

```bash
git clone https://gitlab.com/moveck/pgcs.git
cd pgcs
yarn install
yarn start
```