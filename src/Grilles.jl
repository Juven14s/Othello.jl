# Définir la structure de la grille

struct Grille
    tab::Array{Int, 2}  # La grille 2D pour le jeu

    function Grille()
        # Initialiser l'état de chaque case à 0 pour vide
      new(zeros(Int, 8, 8))  # Créer une grille 8x8 remplie de zéros
    end
end

# Afficher l'état de la grille
function affiche(g::Grille)
    println("  1 2 3 4 5 6 7 8")
    for i in 1:8
        print(i, " ")  # Afficher l'indice de la ligne
        for j in 1:8
            if g.tab[i, j] == 0
                print(". ")
            elseif g.tab[i, j] == 1
                print("X ")
            elseif g.tab[i, j] == 2
                print("O ")
            end
        end
        println()  # Nouvelle ligne après chaque ligne de la grille
    end
end

# Lire l'état d'une case
function getCase(g::Grille, x::Int, y::Int)
    return g.tab[x, y]  # Convertir en index 1 basé
end

# Modifier l'état d'une case
function setCase(g::Grille, x::Int, y::Int, val::Int)
    g.tab[x , y] = val  # Définir une case (1 pour noir, 2 pour blanc)
end

# Calculer le score
function getScore(g::Grille)
    score = 0
    for i in 1:8
        for j in 1:8
            if g.tab[i, j] == 1
                score += 1  # Ajouter 1 pour chaque pion noir
            elseif g.tab[i, j] == 2
                score -= 1  # Soustraire 1 pour chaque pion blanc
            end
        end
    end
    return score
end


mutable struct Jeu
    grille::Grille
    joueurCourant::Int

    function Jeu()
        new(Grille(), 1)  # Initialiser le jeu avec un joueur courant (1 pour noir)
    end
end

# Fonction pour retourner les pions dans une direction donnée
function retourner_direction!(g::Grille, x::Int, y::Int, dx::Int, dy::Int, joueur::Int)
    adversaire = 3 - joueur
    to_flip = []
    
    nx, ny = x + dx, y + dy
    while nx >= 1 && nx <= 8 && ny >= 1 && ny <= 8 && getCase(g, nx, ny) == adversaire
        push!(to_flip, (nx, ny))
        nx += dx
        ny += dy
    end
    
    if nx >= 1 && nx <= 8 && ny >= 1 && ny <= 8 && getCase(g, nx, ny) == joueur
        for (fx, fy) in to_flip
            setCase(g, fx, fy, joueur)
        end
    end
end

# Fonction pour retourner les pions dans toutes les directions
function retourner_pions!(g::Grille, x::Int, y::Int, joueur::Int)
    directions = [(1, 0), (0, 1), (-1, 0), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]
    for (dx, dy) in directions
        retourner_direction!(g, x, y, dx, dy, joueur)
    end
end

function coupValide(jeu::Jeu, x::Int, y::Int)
    g = jeu.grille
    if getCase(g, x, y) != 0
        return false
    end
    adjacent = false
    for i in -1:1, j in -1:1
        if i == 0 && j == 0
            continue
        end
        nx, ny = x + i, y + j
        if nx < 1 || nx > 8 || ny < 1 || ny > 8 || getCase(g, nx, ny) == jeu.joueurCourant
            continue
        end
        while getCase(g, nx, ny) != 0
            nx += i
            ny += j
            if nx < 1 || nx > 8 || ny < 1 || ny > 8
                break
            end
            if getCase(g, nx, ny) == jeu.joueurCourant
                adjacent = true
                break
            end
        end
        if adjacent
            break
        end
    end
    return adjacent
end

function jouer(jeu::Jeu, x::Int, y::Int)
    if coupValide(jeu, x, y)
        setCase(jeu.grille, x, y, jeu.joueurCourant)
        retourner_pions!(jeu.grille, x, y, jeu.joueurCourant)  # Retourner les pions
        jeu.joueurCourant = 3 - jeu.joueurCourant
        return true
    else
        println("!!!!!!!!!!!!!!!!!! \n Coup invalide, recommencez ! \n!!!!!!!!!!!!!!!!!! ")
        return false
    end
end


function coupPossible(jeu::Jeu, joueur::Int)
    for i in 1:8
        for j in 1:8
            if getCase(jeu.grille , i, j) == 0 && coupValide(jeu, i, j)
                return true
            end
        end
    end
    return false
end


function fini(jeu::Jeu)
    nbNoir = 0
    nbBlanc = 0
    nbVide = 0

    # Compter les pièces
    for i in 1:8
        for j in 1:8
            if getCase(jeu.grille , i, j) == 1
                nbNoir += 1
            elseif getCase(jeu.grille , i, j)  == 2
                nbBlanc += 1
            else
                nbVide += 1
            end
        end
    end

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

function executer(jeu::Jeu)
    while true
        affiche(jeu.grille)

        # Demander au joueur courant de jouer
        if jeu.joueurCourant == 1
            println("Joueur noir (X), entrez votre coup (x,y) ) : ")
            x,y = split(readline())
            x = parse(Int,x)
            y = parse(Int,y)
            jouer(jeu, y, x)
        else
            println("Joueur blanc (O), entrez votre coup (x, y) : ")
            x,y = split(readline())
            x = parse(Int,x)
            y = parse(Int,y)
            jouer(jeu, y, x)
        end

        # Vérifier si la partie est finie
        if fini(jeu) != 0
            affiche(jeu.grille)
            break
        end
    end
end

function jeu()
    # Créer une instance de la grille
    #g = Grilles.Grille()
    j = Jeu()

    # Initialiser les quatre premières pièces
    setCase(j.grille, 4, 4, 2)  # Blanc
    setCase(j.grille, 4, 5, 1)  # Noir
    setCase(j.grille, 5, 4, 1)  # Noir
    setCase(j.grille, 5, 5, 2)  # Blanc

  
    executer(j)

end

