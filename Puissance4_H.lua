--dofile("alpha-beta.lua")


LARGEUR = 8
HAUTEUR = 8

JOUEUR1 = 1
JOUEUR2 = 2
VIDE    = 0



function proba(d, f)
   math.randomseed(math.random(1, os.time())/100*math.pi)
   math.random(); math.random(1,math.pi)
   return math.random(d, f)
end 


function nbCoupJouer(e)
 local tmp = 0
 for i=0, LARGEUR-1, 1 do
  for j=0, HAUTEUR-1, 1 do
   if (e.tab[i][j] ~= 0) then tmp = tmp+1 end
  end
 end
 return tmp
end

-- donne la valeur de la case en (i,j) renvois VIDE si la case est hors du plateau
function getCase(t,i,j)
 if (i>=0 and i<LARGEUR and j>=0 and j<HAUTEUR)
  then
   --print("acces à ("..i..","..j.."..) = "..t[i][j])
   return t[i][j]
  else return VIDE
 end
end

-- verifie dans une liste de case si on a un gagnant
function verifListe(l, nb, j)
 --print("le joueur cherché est ------->   "..j)
 local compteur = 0
 local chaine = ""
 for i=0, nb-1, 1 do
  chaine = chaine.." "..l[i]
  if (l[i] == j)
   then compteur = compteur + 1
        if (compteur == 4) then return true
        end
   else compteur = 0
   end
 end
 --print(chaine)
 return false
end

-- verifie si l'etat est gagnant pour le dernier joueur
function gagne(e)
 --print("entree dans gagne")
 local joueur = e.j
 --print("copie du plateau...")
 local tab = copie(e.tab)
 --print(" -> ok\n dernier coup ...")
 local c = e.dernierCoup
--  print("ok apres dernier coup")
 if (c == -1) then return false
 else
--   print("debut du else")
  local l = prochCaseVide(tab[c]) -1
  --print("\nrecherche dans le plateau suivant")
  --printEtat_console(e,"####")
  --print("cherche le joueur "..joueur.."\n")
  -- recuperation de 4 listes de cases susceptible de contenir un 4-a-la-suite
  local liste = {}
 -- horizontale
 liste[0] = getCase(tab,c-3,l)
 liste[1] = getCase(tab,c-2,l)
 liste[2] = getCase(tab,c-1,l)
 liste[3] = getCase(tab,c,l)
 liste[4] = getCase(tab,c+1,l)
 liste[5] = getCase(tab,c+2,l)
 liste[6] = getCase(tab,c+3,l)
 --verif
--  print("horizontal")
 if (verifListe(liste, 7, joueur)) then return true end
--  print("non")
 -- verticale
 liste[0] = getCase(tab,c,l-3)
 liste[1] = getCase(tab,c,l-2)
 liste[2] = getCase(tab,c,l-1)
 liste[3] = getCase(tab,c,l)
 --verif
--  print("vertical")
 if (verifListe(liste, 4, joueur)) then return true end
--  print("non")
 -- diag \
 liste[0] = getCase(tab,c-3,l+3)
 liste[1] = getCase(tab,c-2,l+2)
 liste[2] = getCase(tab,c-1,l+1)
 liste[3] = getCase(tab,c,l)
 liste[4] = getCase(tab,c+1,l-1)
 liste[5] = getCase(tab,c+2,l-2)
 liste[6] = getCase(tab,c+3,l-3)
 --verif
--  print("\\")
 if (verifListe(liste, 7, joueur)) then return true end
 --print("non")
 -- diag /
 liste[0] = getCase(tab,c-3,l-3)
 liste[1] = getCase(tab,c-2,l-2)
 liste[2] = getCase(tab,c-1,l-1)
 liste[3] = getCase(tab,c,l)
 liste[4] = getCase(tab,c+1,l+1)
 liste[5] = getCase(tab,c+2,l+2)
 liste[6] = getCase(tab,c+3,l+3)
 --verif
 --print("/")
 if (verifListe(liste, 7, joueur)) then return true end
 --print("non")
 return false
 end -- fin du else (tt en haut)
end



-- creer un etat vide
function etatVide()
 local res = {j = 1 ,tab = {}, dernierCoup = -1}
 local i = 0
 local j = 0
 for i=0, LARGEUR-1, 1 do
  res.tab[i] = {}
  for j=0, HAUTEUR-1, 1 do
   res.tab[i][j] = VIDE
  end
 end
 return res
end


-- regarde si un etat est final
function etatFinal(e)
 local Gagnee = gagne(e)
 --print("entre gagne et coupAuPif")
 local CoupPossible = coupAuPif(e)
 --print("apres coupAuPif")
 if ( Gagnee or CoupPossible == -1)
  then
   --printEtat_console(e,"-->")
   --print("etat final")
   return true
  else
   --printEtat_console(e,"-->")
   --print("etat NON final")
   return false
 end
end



-- donne le joueur suivant
function joueurSuivant(j)
 if (j == JOUEUR1) then return JOUEUR2
 else return JOUEUR1
 end
end

-- donne le numero de la ligne de la prochaine case vide de la colone
function prochCaseVide(t)
 local i=0
 for i=0, HAUTEUR-1, 1 do
  if t[i] ==VIDE then return i end
 end
 return HAUTEUR
end


-- copie un tableau
function copie(t)
 local res = {}
 for i=0, LARGEUR-1, 1 do
  res[i] = {}
  for j=0, HAUTEUR-1, 1 do
   res[i][j] = t[i][j]
  end
 end
 return res
end



-------------------------------------- affichage console
-- valable pour une largeur de 8
function printEtat_console(e,prefixe)
 local i = 0
 local j = 0
 for i=HAUTEUR-1, 0, -1 do
  chaine = prefixe.."[ "
  for j=0, LARGEUR-1, 1 do
   if e.tab[j][i] == 0
    then chaine = chaine.."  "
    else chaine = chaine..e.tab[j][i].." "
   end
  end
  print(chaine.."]")
 end
 print(prefixe.."-------------------")
 print(prefixe.."[ 0 1 2 3 4 5 6 7 ]\ndernier joueur "..e.j.."\ndernier coup "..e.dernierCoup)
end

-- choisi une case au pif parmis tt celles qui sont jouables
function coupAuPif(e)
 local coupPossible = {}
 local j = 0
 for i=0, LARGEUR-1, 1 do
  if (prochCaseVide(e.tab[i]) ~= HAUTEUR) then
   coupPossible[j] = i
   j = j+1
  end -- fin du if
 end -- fin du for
 if j==0
  then return -1
  else return coupPossible[proba(0,j-1)]
 end
end

function coupGagnant(e,c,j)
 local tmp = {j=j, tab=copie(e.tab), dernierCoup = c}
 local idLigne = prochCaseVide(e.tab[c])
 tmp.tab[c][idLigne] = j
 return gagne(tmp)
end

function getCoupsPossibles(e)
 -- recupere la liste des coups possibles
 local coupPossible = {nb=0, tab = {}}
 local j = 0
 for i=0, LARGEUR-1, 1 do
  if (prochCaseVide(e.tab[i]) ~= HAUTEUR) then
   coupPossible.tab[j] = i
   j = j+1
  end -- fin du if
 end -- fin du for
 coupPossible.nb = j
 return coupPossible
end

-- fonction qui choisie un coup pas trop mal

function choisiCoup(e)
 local joueur = joueurSuivant(e.j)
 -- 
   -- joue le 1er coup au centre pour pas se faire couilloner
   if (nbCoupJouer(e) < 3) then
    --print("joue au centre")
    if e.tab[3][0] == VIDE
     then return 3
     elseif e.tab[4][0] == VIDE then return 4
    end
   end
 --
 local coupPossible = getCoupsPossibles(e)
 local j = coupPossible.nb
 -- regarde si il peut gagner
 for i=0, j-1, 1 do
  if (coupGagnant(e,coupPossible.tab[i], joueur))
   then --print("coup gagnant")
        return coupPossible.tab[i]
   else --print("pas coup gagnant")
  end -- fin du if
 end -- fin du for

 -- regarde si il peut empecher l'autre de gagner
 for i=0, j-1, 1 do
  if (coupGagnant(e,coupPossible.tab[i], e.j))
   then --print("empeche de gagner")
        return coupPossible.tab[i]
   else --print("pas empeche de gagner")
  end -- fin du if
 end -- fin du for

 -- l'empeche de faire une grosse connerie
 local coupPotable ={}
 local nbCoupPotable = 0
 
 for i=0, j-1, 1 do
  -- construit l'etat suivant possible
  local tmp = {j=joueur, tab=copie(e.tab), dernierCoup = coupPossible.tab[i]}
  local idLigne = prochCaseVide(e.tab[coupPossible.tab[i]])
  tmp.tab[coupPossible.tab[i]][idLigne] = joueur
  -- regarde si le joueur suivant peut gagner

  local coupsSuivants = getCoupsPossibles(tmp)
  local l = coupsSuivants.nb
  local suivantGagne = false
  for k=0, l-1, 1 do
   if (coupGagnant(tmp,coupsSuivants.tab[k], joueurSuivant(joueur)))
    then suivantGagne = true
         --print("coup potable")
    else --print("coup pourris")
   end -- fin du if
  end -- fin du for
  --print("le coup en "..coupPossible.tab[i].." est potable")
  if suivantGagne == false then
    coupPotable[nbCoupPotable] = coupPossible.tab[i]
    nbCoupPotable = nbCoupPotable +1
  end
 end -- fin du for
 -- ici il faut choisir parmis les coups potables
 if (nbCoupPotable < 1)
  then return coupPossible.tab[proba(0,coupPossible.nb-1)]
  else return coupPotable[proba(0,nbCoupPotable-1)]
 end
 
end


-- e= etatVide()
-- print("choisie dans")
-- printEtat_console(e,"")
-- print(choisiCoup(e))


-------------------------------------------------------
-------------  POUR TESTER SUR UN PC  -----------------
-------------------------------------------------------
--[[

cpt = 0
etatCourant = etatVide()
continuer = true
jcour = 2
while continuer do
 -- fais jouer le jeu
 cpt = cpt+1
 local coup = choisiCoup(etatCourant)
 print(cpt.." -> le joueur joue en "..coup)
 etatCourant.j = joueurSuivant(etatCourant.j)
 etatCourant.dernierCoup = coup
 local idLigne = prochCaseVide(etatCourant.tab[coup])
 etatCourant.tab[coup][idLigne] = etatCourant.j
 -- verifie si qqun a gange ?
 if (etatFinal(etatCourant)) then continuer = false end
 printEtat_console(etatCourant,"")
 print("------------------------")
 jcour= joueurSuivant(jcour)
 if cpt > 2 then continuer = false end
end

if gagne(etatCourant) then print("GAGNE !") end
]]