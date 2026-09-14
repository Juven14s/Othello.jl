using Othello
using Test

function partie_initiale()
    jeu = Othello.Jeu()
    Othello.setCase(jeu.grille, 4, 4, 2)
    Othello.setCase(jeu.grille, 4, 5, 1)
    Othello.setCase(jeu.grille, 5, 4, 1)
    Othello.setCase(jeu.grille, 5, 5, 2)
    return jeu
end

@testset "Othello.jl" begin
    @testset "Grille initiale" begin
        jeu = partie_initiale()
        @test Othello.getScore(jeu.grille) == 0
        @test count(==(1), jeu.grille.tab) == 2
        @test count(==(2), jeu.grille.tab) == 2
        @test count(==(0), jeu.grille.tab) == 60
    end

    @testset "Validation des coups" begin
        jeu = partie_initiale()

        # Les quatre coups classiques disponibles pour le joueur noir au départ.
        @test Othello.coupValide(jeu, 3, 4)
        @test Othello.coupValide(jeu, 4, 3)
        @test Othello.coupValide(jeu, 5, 6)
        @test Othello.coupValide(jeu, 6, 5)

        @test !Othello.coupValide(jeu, 4, 4) # case occupée
        @test !Othello.coupValide(jeu, 1, 1) # aucune capture
        @test !Othello.coupValide(jeu, 0, 1) # hors grille
        @test !Othello.coupValide(jeu, 9, 1) # hors grille
    end

    @testset "Jouer retourne les pions et change de joueur" begin
        jeu = partie_initiale()
        @test Othello.jouer(jeu, 3, 4)
        @test Othello.getCase(jeu.grille, 3, 4) == 1
        @test Othello.getCase(jeu.grille, 4, 4) == 1
        @test jeu.joueurCourant == 2
    end

    @testset "Recherche des coups pour un joueur précis" begin
        jeu = Othello.Jeu()
        Othello.setCase(jeu.grille, 1, 1, 2)
        Othello.setCase(jeu.grille, 1, 2, 1)
        jeu.joueurCourant = 1

        # Le joueur 1 n'a aucun coup, mais le joueur 2 peut jouer en (1, 3).
        @test !Othello.coupPossible(jeu, 1)
        @test Othello.coupPossible(jeu, 2)
        @test Othello.coupValide(jeu, 1, 3, 2)

        # La partie ne doit pas être déclarée terminée uniquement parce que
        # le joueur courant n'a pas de coup.
        @test Othello.fini(jeu) == 0
    end

    @testset "Passage automatique du tour" begin
        jeu = Othello.Jeu()
        Othello.setCase(jeu.grille, 1, 1, 2)
        Othello.setCase(jeu.grille, 1, 2, 1)
        jeu.joueurCourant = 1

        @test Othello.passer_si_necessaire!(jeu)
        @test jeu.joueurCourant == 2
        @test !Othello.passer_si_necessaire!(jeu)
    end

    @testset "Fin de partie" begin
        jeu = Othello.Jeu()
        jeu.grille.tab .= 1
        @test Othello.fini(jeu) == 1

        jeu.grille.tab .= 2
        @test Othello.fini(jeu) == 2

        for i in eachindex(jeu.grille.tab)
            jeu.grille.tab[i] = isodd(i) ? 1 : 2
        end
        @test Othello.fini(jeu) == 3
    end
end
