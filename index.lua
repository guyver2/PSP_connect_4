--[[ PsPuissance 4 par Antoine Letouzey
     ameboure@yahoo.fr
     http://sexy-banane.mine.nu/~peter/jeux.php
]]

-- chargement du fichier contenant toutes les fct
dofile("./Puissance4_H.lua")

-- chargement des images
ImFond = Image.load ("datas/fond2.png")
ImPion = {}
ImPion[1] = Image.load("datas/pion1.png")
ImPion[2] = Image.load("datas/pion2.png")
Select = Image.load("datas/select.png")
ImGagne = Image.load("datas/gagne.png")
ImPerdu = Image.load("datas/perdu.png")
ImIntro = Image.load("datas/intro.png")

-- constantes propres a la PSP
CONTINUER = true
QUITTER = false
RED = Color.new(255,0,0)
GRIS = Color.new(124,124,124)


-- varaibles globales sur l'etat du jeu (pas tip top mais bon...)

nbVictoires = 0
nbDefaites  = 0
nbCoupJoues = 0
proportional = Font.createProportional()
info = Font.createProportional()
proportional:setPixelSizes(0, 20)
info:setPixelSizes(0, 10)


---------------------------------------------------------
---------------      Fonctions     ----------------------
---------------------------------------------------------



-- ##  valable pour une largeur de 8
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

-- ##   Affichage du plateau pour la psp
function printEtat_psp(e, ySelect)
 screen:clear()
 screen:blit(0,0,ImFond)
 for i=0, HAUTEUR-1, 1 do
  for j=LARGEUR-1, 0, -1 do
   if ((e.tab[j][i]) ~= VIDE) then
    screen:blit(j*32+113,(HAUTEUR-(1+i))*32+9,ImPion[e.tab[j][i]])
   end -- if
  end -- for j
 end -- for i
 
 if (ySelect ~=-1) then screen:blit(115+ySelect*32,259,Select) end
end



-- ##  Affichage des infos sur les parties jouees et en cours
function printInfo()
 screen:fontPrint(proportional, 44, 67, nbVictoires, GRIS)
 screen:fontPrint(proportional, 44, 120, nbDefaites, GRIS)
 local decalage = 0
 if (nbCoupJoues >= 10) then decalage = 9 end
 screen:fontPrint(proportional, 44-decalage, 180, nbCoupJoues, GRIS)
end


-- ##  fais choisir une colone au joueur humain
function choix(e)
 local coloneChoisie = -1
 local select = 3
 local touchelibre = 30
 printEtat_psp(e,select)
 printInfo()
 screen.flip()
 screen.waitVblankStart()
 -- on attend que le joueur choisisse une colone
 while (CONTINUER and (coloneChoisie == -1)) do
  local pad = Controls.read()
  if (pad:left() and touchelibre==0) then
   touchelibre = 12
   select = select - 1
   select = select - math.floor(select/8)*8
   printEtat_psp(e,select)
   printInfo()
   screen.flip()
   screen.waitVblankStart()
  elseif (pad:right() and touchelibre==0) then
   touchelibre = 12
   select = select + 1
   select = select - math.floor(select/8)*8
   printEtat_psp(e,select)
   printInfo()
   screen.flip()
   screen.waitVblankStart()
  elseif (pad:select()) then
   --screen:save("shot-p4.png")
   os.exit()
   break
  elseif (touchelibre>0) then touchelibre = touchelibre-1
  end
  if (touchelibre==0 and pad:cross() and (prochCaseVide(e.tab[select]) < HAUTEUR)) then coloneChoisie = select end
 end -- fin du while
 -- ici on a une case valide
 if (CONTINUER) then
  e.j = joueurSuivant(e.j)
  e.tab[coloneChoisie][prochCaseVide(e.tab[coloneChoisie])] = e.j
  e.dernierCoup = coloneChoisie
 end
end


-----------------------------------------------------------------
----------------         JEU           --------------------------
-----------------------------------------------------------------

nbVictoires = 0
nbDefaites  = 0


-- ##  jeu principal

while (CONTINUER and (QUITTER == false)) do

-- INTRO

while (CONTINUER and (QUITTER == false)) do
 screen:blit(0,0,ImIntro);
 screen:fontPrint(info, 77, 126, "[Start]    => commencer", RED)
 screen:fontPrint(info, 77, 140, "[Select] => quitter", RED)
 --screen:print(77,126,"[Start]  => commencer",RED)
 --screen:print(77,136,"[Select] => quitter",RED)
 screen.flip()
 screen.waitVblankStart()
 local pad = Controls.read()
 if pad:start()  then 
 CONTINUER = false
 end
 if pad:select() then 
 os.exit()
 end
end -- fin de la boucle d'intro


CONTINUER = true



-- jeu normal

nbCoupJoues = 0
etatCourant = etatVide()

while (CONTINUER and (QUITTER == false)) do
 if (etatCourant.j == 1)
  then choix(etatCourant)
  else local coup = choisiCoup(etatCourant)
       etatCourant.j = joueurSuivant(etatCourant.j)
       etatCourant.dernierCoup = coup
       local idLigne = prochCaseVide(etatCourant.tab[coup])
       etatCourant.tab[coup][idLigne] = etatCourant.j
 end
 printEtat_psp(etatCourant,-1)
 printInfo()
 screen.flip()
 screen.waitVblankStart()
 if (etatFinal(etatCourant)) then CONTINUER = false end

 nbCoupJoues = nbCoupJoues + 1
end -- fin de la boucle du jeu normal



if (gagne(etatCourant))
 then gagnant = etatCourant.j
 else gagnant = joueurSuivant(etatCourant.j)
end

if (gagnant == JOUEUR1)
 then nbDefaites = nbDefaites + 1
 else nbVictoires = nbVictoires + 1
end

CONTINUER = true

-- fin de partie
while (CONTINUER and (QUITTER == false)) do
 printEtat_psp(etatCourant,-1)
 printInfo()
 if (gagnant == JOUEUR1)
  then screen:blit(152,100,ImPerdu)
  else screen:blit(152,100,ImGagne)
 end
 screen:fontPrint(info, 391, 31, "Rejouer ?", RED)
 screen:fontPrint(info, 391, 51, "[O]", RED)
 screen:fontPrint(info, 391, 81, "Quitter ?", RED)
 screen:fontPrint(info, 391, 101, "[SELECT]", RED)
 --screen:print(0,262,"[O]  => rejouer",RED)
 --screen:print(150,262,"[Select]  => quitter",RED)
 screen.flip()
 screen.waitVblankStart()
 local pad = Controls.read()
 if pad:circle() then 
 CONTINUER = false 
 end
 if pad:select() then 
 os.exit()
 end
end -- fin de la boucle de l'ecran de fin

CONTINUER = true

end
