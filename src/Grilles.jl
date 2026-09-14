struct Grille
    tab::Array{Int, 2}

    function Grille()
        new(zeros(Int, 8, 8))
    end
end

const DIRECTIONS = (
    (1, 0), (0, 1), (-1, 0), (0, -1),
    (1, 1), (1, -1), (-1, 1), (-1, -1),
)

# Vérifie qu'une position appartient à la grille.
dans_grille(x::Int, y::Int) = 1 <= x <= 8 && 1 <= y <= 8

# Afficher l'état de la grille.
function affiche(g::Grille)
    println("  1 2 3 4 5 6 7 8")
    for i in 1:8
        print(i, " ")
        for j in 1:8
            if g.tab[i, j] == 0
                print(". ")
            elseif g.tab[i, j] == 1
                print("X ")
            elseif g.tab[i, j] == 2
                print("O ")
            end
        end
        println()
    end
end

# Lire l'état d'une case.
getCase(g::Grille, x::Int, y::Int) = g.tab[x, y]

# Modifier l'état d'une case.
function setCase(g::Grille, x::Int, y::Int, val::Int)
    g.tab[x, y] = val
end

# Calculer le score : positif pour noir, négatif pour blanc.
function getScore(g::Grille)
    score = 0
    for case in g.tab
        if case == 1
            score += 1
        elseif case == 2
            score -= 1
        end
    end
    return score
end

mutable struct Jeu
    grille::Grille
    joueurCourant::Int

    function Jeu()
        new(Grille(), 1)
    end
end

# Retourne vrai si le coup capture au moins un pion dans une direction donnée.
function capture_direction(g::Grille, x::Int, y::Int, dx::Int, dy::Int, joueur::Int)
    adversaire = 3 - joueur
    nx, ny = x + dx, y + dy
    a_trouve_adversaire = false

    while dans_grille(nx, ny) && getCase(g, nx, ny) == adversaire
        a_trouve_adversaire = true
        nx += dx
        ny += dy
    end

    return a_trouve_adversaire && dans_grille(nx, ny) && getCase(g, nx, ny) == joueur
end

# Retourner les pions dans une direction donnée.
function retourner_direction!(g::Grille, x::Int, y::Int, dx::Int, dy::Int, joueur::Int)
    capture_direction(g, x, y, dx, dy, joueur) || return

    adversaire = 3 - joueur
    nx, ny = x + dx, y + dy
    while dans_grille(nx, ny) && getCase(g, nx, ny) == adversaire
        setCase(g, nx, ny, joueur)
        nx += dx
        ny += dy
    end
end

# Retourner les pions dans toutes les directions.
function retourner_pions!(g::Grille, x::Int, y::Int, joueur::Int)
    for (dx, dy) in DIRECTIONS
        retourner_direction!(g, x, y, dx, dy, joueur)
    end
end

"""
    coupValide(jeu, x, y, joueur=jeu.joueurCourant)

Indique si `(x, y)` est un coup légal pour `joueur`.
"""
function coupValide(jeu::Jeu, x::Int, y::Int, joueur::Int=jeu.joueurCourant)
    joueur in (1, 2) || return false
    dans_grille(x, y) || return false
    getCase(jeu.grille, x, y) == 0 || return false

    return any(
        capture_direction(jeu.grille, x, y, dx, dy, joueur)
        for (dx, dy) in DIRECTIONS
    )
end

function jouer(jeu::Jeu, x::Int, y::Int)
    joueur = jeu.joueurCourant
    if !coupValide(jeu, x, y, joueur)
        println("!!!!!!!!!!!!!!!!!!\nCoup invalide, recommencez !\n!!!!!!!!!!!!!!!!!!")
        return false
    end

    setCase(jeu.grille, x, y, joueur)
    retourner_pions!(jeu.grille, x, y, joueur)
    jeu.joueurCourant = 3 - joueur
    return true
end

# Vérifie si un joueur précis possède au moins un coup légal.
function coupPossible(jeu::Jeu, joueur::Int)
    joueur in (1, 2) || return false
    for i in 1:8, j in 1:8
        if coupValide(jeu, i, j, joueur)
            return true
        end
    end
    return false
end

# Passe le tour uniquement si le joueur courant n'a aucun coup et que l'adversaire peut jouer.
function passer_si_necessaire!(jeu::Jeu)
    joueur = jeu.joueurCourant
    if !coupPossible(jeu, joueur) && coupPossible(jeu, 3 - joueur)
        jeu.joueurCourant = 3 - joueur
        return true
    end
    return false
end

function fini(jeu::Jeu)
    nbNoir = count(==(1), jeu.grille.tab)
    nbBlanc = count(==(2), jeu.grille.tab)
    nbVide = count(==(0), jeu.grille.tab)

    if nbVide == 0 || (!coupPossible(jeu, 1) && !coupPossible(jeu, 2))
        if nbNoir > nbBlanc
            println("Le joueur noir (X) a gagné !")
            return 1
        elseif nbBlanc > nbNoir
            println("Le joueur blanc (O) a gagné !")
            return 2
        else
            println("Match nul.")
            return 3
        end
    end

    return 0
end

# Lit deux coordonnées et redemande la saisie si elle est invalide.
function lire_coup()
    while true
        valeurs = split(strip(readline()))
        if length(valeurs) != 2
            println("Entrez deux coordonnées séparées par un espace, par exemple : 4 3")
            continue
        end

        try
            x, y = parse.(Int, valeurs)
            if dans_grille(x, y)
                return x, y
            end
            println("Les coordonnées doivent être comprises entre 1 et 8.")
        catch err
            if err isa ArgumentError
                println("Les coordonnées doivent être des nombres entiers.")
            else
                rethrow()
            end
        end
    end
end

function executer(jeu::Jeu)
    while true
        resultat = fini(jeu)
        if resultat != 0
            affiche(jeu.grille)
            break
        end

        if passer_si_necessaire!(jeu)
            println("Aucun coup possible : le tour est passé.")
            continue
        end

        affiche(jeu.grille)
        symbole = jeu.joueurCourant == 1 ? "noir (X)" : "blanc (O)"
        println("Joueur $symbole, entrez votre coup (colonne ligne), par exemple : 4 3")
        x, y = lire_coup()
        jouer(jeu, y, x)
    end
end

function jeu()
    j = Jeu()

    # Initialiser les quatre premières pièces.
    setCase(j.grille, 4, 4, 2)
    setCase(j.grille, 4, 5, 1)
    setCase(j.grille, 5, 4, 1)
    setCase(j.grille, 5, 5, 2)

    executer(j)
end
