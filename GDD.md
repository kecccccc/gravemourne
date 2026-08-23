# Gravemourne

### Game Design Document

Autor: [IME I PREZIME]
Broj indeksa: [BROJ INDEKSA]
Datum: avgust 2026.
Verzija: 1.0 (opisuje trenutno stanje implementacije)

---

## 1. Svrha dokumenta

Ovaj dokument opisuje igru Gravemourne u njenom trenutnom stanju razvoja, onako kako je implementirana u Godot Engine 4.6 projektu. Cilj dokumenta nije da predstavi apstraktnu zamisao ili plan za budućnost, nego da vrlo konkretno opiše šta igra radi danas: koje mehanike postoje, kako su napravljene, kakva je struktura scena i skripti, koji su objekti u igri i kako se oni ponašaju. Sve informacije u ovom dokumentu su izvedene direktno iz koda i scena projekta (fajlovi .tscn i .gd), a ne iz ideje ili sećanja o tome kako bi igra trebalo da izgleda.

Dokument je pisan tako da može poslužiti u dve svrhe. Prva je akademska, kao deo predaje projekta iz predmeta koji obrađuje razvoj igara ili softversko inženjerstvo. Druga je praktična, kao referentni materijal za dalji rad na projektu, jer sadrži pregled tehničke arhitekture koji olakšava snalaženje u kodu nekome ko se prvi put susreće sa ovim projektom, uključujući i samog autora posle duže pauze u radu.

Tamo gde nešto u kodu deluje nedovršeno, nekonzistentno ili kao ostatak ranije verzije dizajna, to je eksplicitno navedeno kao takvo, umesto da se prećutkuje ili predstavlja kao namerna odluka. Cilj je da dokument bude iskren opis stanja projekta, a ne uglađena prezentacija.

Napomena o rezoluciji i strukturi nivoa: prilikom pisanja ovog dokumenta upoređeni su prvobitni opisi projekta sa stvarnim sadržajem project.godot fajla i scena nivoa. Rezolucija viewporta u ovom dokumentu (640x360) preuzeta je direktno iz project.godot, a broj nivoa (tri) direktno iz postojećih scena level_1.tscn, level_2.tscn i level_3.tscn, jer se ove vrednosti razlikuju od prvobitne pretpostavke.

## 2. Opis igre

Gravemourne je dvodimenzionalna akciona igra u pixel art stilu, sa elementima metroidvania i souls-like žanra. Radi se u Godot Engine 4.6.2, koristeći GDScript kao jedini programski jezik u projektu. Igra se prikazuje iz bočne perspektive (side-scroller), sa kamerom koja je vezana direktno za igrača i prati njegovo kretanje kroz nivo.

Igrač preuzima ulogu lovca koji dolazi u grad po imenu Gravemourne. Grad je nekada bio naseljen, ali je utihnuo kada se tama uzdigla ispod zemlje. Mrtvi su ustali, živi su pobegli, a ono što je ostalo su ruševine i nemrtva stvorenja. Uvodni tekst igre, koji se prikazuje na početku nove igre, ovo opisuje sledećim rečima: igrač je lovac bez mape i saveznika, sa mačem i voljom da istraje, čiji je zadatak da pronađe izvor zla i okonča ga, ili da se pridruži grobovima.

Igra je strukturirana kao niz od tri povezana nivoa kroz koje se igrač kreće linearno, boreći se protiv raznih tipova nemrtvih neprijatelja, sakupljajući napitke zdravlja i ključeve, i na kraju se suočava sa finalnim bosom. Ton igre je taman i gotički, što se ogleda u vizuelnom stilu (kamene ruševine, gotički enterijeri, groblja), u izboru fontova (gotički blackletter font i dekorativni serifni fontovi) i u boji koja se dosledno koristi za tekst kroz čitavu igru (toplo zlatno-bronzana nijansa).

Za razliku od klasičnog metroidvania žanra, igra trenutno nema sistem otključavanja novih sposobnosti ili slobodno istraživanje mape u više pravaca. Napredovanje je linearno, od jednog nivoa ka sledećem, kroz vrata koja se otključavaju ispunjavanjem određenog uslova (poraz neprijatelja ili posedovanje ključa). Souls-like elementi se ogledaju u dizajnu borbe: napadi imaju animacije koje se moraju odigrati do kraja, postoji prozor nepovredivosti posle primljenog udarca, a smrt igrača vraća ceo nivo na početak.

## 3. Cilj igre

Cilj igre, posmatrano na nivou cele partije, jeste da igrač prođe kroz sva tri nivoa grada Gravemourne i porazi finalnog bosa na kraju trećeg nivoa. Kada finalni bos bude poražen, igra prikazuje završni ekran sa tekstom koji zaokružuje priču, posle čega se igrač vraća na glavni meni.

Na nivou pojedinačnog nivoa, cilj je doći do vrata na kraju nivoa i ispuniti uslov koji ih otključava. U prvom nivou taj uslov je poraz neprijatelja iz grupe "executioner" (izvršilac), dok je u drugom nivou uslov posedovanje ključa koji ispada od poraženog mini-bosa bigSkelly. Treći nivo nema vrata, već se završava direktno porazom finalnog bosa.

Na nivou pojedinačne borbe, cilj je preživeti sudar sa neprijateljem koristeći kombinaciju kretanja, dvostrukog skoka i napada mačem, uz izbegavanje udaraca kad god je to moguće, jer svaki primljeni udarac oduzima poene zdravlja. Kada zdravlje igrača padne na nulu, nivo se ponovo pokreće od početka.

Igra trenutno nema sistem bodovanja, tabelu rezultata, niti sekundarne, opcione ciljeve (kao što su skriveni predmeti ili dodatni izazovi). Jedini merljivi napredak je to koliko daleko je igrač stigao kroz tri nivoa i da li je uspeo da porazi finalnog bosa.

## 4. Gameplay

Partija počinje na glavnom meniju, gde igrač bira između opcija Play, Controls, Options i Quit. Izborom opcije Play, dugmad glavnog menija nestaju kroz postepeno iščezavanje (fade out), a zatim se prikazuje uvodni tekst priče preko celog ekrana. Kada tekst bude u potpunosti prikazan, igra čeka da igrač pritisne bilo koji taster ili klikne mišem, posle čega se ekran zacrni i učitava se prvi nivo (level_1.tscn). U tom trenutku se takođe kreira sačuvani podatak o trenutnom nivou preko GameManager autoload skripte.

Unutar nivoa, igrač se kreće levo i desno, skače (uključujući dvostruki skok u vazduhu) i napada mačem. Nivoi sadrže statične platforme napravljene pomoću TileMap čvora, pozadinske slojeve sa efektom paralakse koji stvaraju utisak dubine, neprijatelje raspoređene po nivou, napitke zdravlja koji leže na fiksnim pozicijama ili ispadaju iz poraženih neprijatelja, i zonu smrti (KillZone) koja trenutno ubija igrača ako uđe u nju, na primer ako padne van granica nivoa.

Borba se odvija u realnom vremenu. Neprijatelji koji imaju zonu detekcije počinju da jure igrača kada im on priđe dovoljno blizu, a kada mu priđu na domet napada, počinju da ga napadaju, sa različitim tajmerima čekanja između napada u zavisnosti od tipa neprijatelja. Igrač uzvraća napadima mačem koji imaju kratak zamah i moraju se odigrati do kraja pre nego što se može ponovo napasti. Kada neprijatelj izgubi svo zdravlje, umire (kroz animaciju smrti) i uklanja se iz scene, a neki tipovi neprijatelja pri tome ostavljaju za sobom predmet, poput napitka zdravlja ili ključa.

Kada igrač dođe do vrata na kraju nivoa i ispuni potrebni uslov, može da ih aktivira tasterom za interakciju, što pokreće zatamnjenje ekrana i prelazak na sledeći nivo. Ako izgubi svo zdravlje pre toga, umesto prelaska na sledeći nivo prikazuje se ekran "YOU DIED" i nivo se ponovo učitava od početka, bez ikakvog sačuvanog napretka unutar tog nivoa.

Poslednji nivo se sastoji isključivo od arene finalnog bosa, bez dodatnih manjih neprijatelja. Kada bos izgubi svo zdravlje, njegova skripta preuzima kontrolu nad tokom igre: zamrzava igrača, pušta animaciju smrti bosa, pravi zatamnjenje ekrana i prebacuje igru na posebnu scenu sa završnim tekstom (ending.tscn), posle čega se igrač, posle izvesnog vremena ili pritiskom bilo kog tastera, vraća na glavni meni.

## 5. Kontrole

| Akcija | Taster / kontrola |
|---|---|
| Kretanje levo | A ili strelica levo |
| Kretanje desno | D ili strelica desno |
| Skok (uključujući dvostruki skok) | Space |
| Napad | K ili levi klik miša |
| Interakcija sa vratima | E |

Ove kontrole su definisane u Input Map sekciji project.godot fajla kroz akcije move_left, move_right, jump, attack i interact, i koriste se dosledno u player.gd i door.gd skriptama. Vredi napomenuti da ekran sa kontrolama u glavnom meniju (opisan u poglavlju 7) trenutno prikazuje samo prva tri reda ove tabele, MOVE, JUMP i ATTACK, dok taster za interakciju sa vratima (E) nije naveden na tom ekranu iako postoji i koristi se u igri.

## 6. Mehanike igre

### Kretanje i dupli skok

Kretanje igrača je implementirano u player.gd, u funkciji _physics_process. Igrač se kreće konstantnom brzinom (SPEED = 200) u horizontalnom pravcu, na osnovu ulaza sa tastature (move_left / move_right), dok se gravitacija primenjuje ručno preko get_gravity() * delta kada igrač nije na tlu. Kada nema horizontalnog ulaza, brzina se postepeno svodi na nulu funkcijom move_toward, umesto da se naglo zaustavi.

Skok koristi konstantu JUMP_VELOCITY = -400 i sistem brojanja skokova (jump_count), sa maksimumom od dva skoka (MAX_JUMPS = 2) pre nego što je potrebno ponovo dodirnuti tlo. Brojač skokova se resetuje na nulu svaki put kada igrač dodirne pod (is_on_floor()). Ovim mehanizmom je ostvaren dupli skok, drugi skok u vazduhu, bez posebne animacije koja bi ga razlikovala od prvog. Trenutak sletanja na tlo se detektuje poređenjem trenutnog i prethodnog stanja is_on_floor() (promenljiva was_on_floor), i tada se pušta zvuk doskoka.

Zvuk trčanja se pušta u petlji dok se igrač kreće po tlu, a zaustavlja se čim se igrač zaustavi ili napusti tlo. Animacije kretanja (idle, run, jump) se biraju u posebnoj funkciji player_animations, koja ne menja animaciju ako je igrač trenutno u stanju napada ili nepovredivosti, kako se te animacije ne bi prekidale.

### Sistem napada

Napad igrača je implementiran kao kratka, neisprekidana akcija. Kada igrač pritisne taster za napad i trenutno ne napada (is_attacking == false), poziva se funkcija attack(), koja postavlja is_attacking na true, pušta zvuk napada i animaciju "attack", pa posle kratkog kašnjenja od 0.1 sekunde proverava koje se neprijateljske zone preklapaju sa AttackArea igrača (attack_area.get_overlapping_areas()). Svakom pronađenom neprijatelju iz grupe "enemy" se poziva take_damage(1). Posle završetka animacije napada, is_attacking se vraća na false i igrač ponovo može da napadne.

Ovakav pristup znači da igrač nanosi štetu u jednom trenutku tokom animacije (posle 0.1s), a ne kontinuirano tokom čitavog trajanja zamaha, i da ne postoji poseban tajmer hlađenja (cooldown) posle napada, osim same dužine animacije. Zanimljivo je da ovaj sistem detekcije radi suprotno od načina na koji neprijatelji nanose štetu igraču: neprijatelji uglavnom koriste signal body_entered na svojoj AttackArea zoni koji se aktivira automatski kada igrač fizički uđe u zonu, dok igračev napad ručno, jednokratno proverava koje se zone trenutno preklapaju sa njegovom AttackArea zonom u jednom određenom trenutku.

Zona napada (AttackArea) se ne postavlja fiksno u uređivaču scena, već se njena pozicija po x-osi menja u svakom fizičkom frejmu u zavisnosti od toga u kom pravcu je igrač okrenut. Ovaj pristup je detaljnije opisan u poglavlju 9, jer se isti obrazac ponavlja i kod neprijatelja.

### Sistem zdravlja i i-frames

Igrač ima 10 poena zdravlja (max_health, podesivo kao @export promenljiva u player.gd), a svaki uspešan pogodak neprijatelja obično oduzima 1 poen (take_damage(1)), sa izuzetkom izvršioca (executioner), čiji napad sastavljen od dva zamaha može da nanese ukupno 2 poena štete u jednom napadu ako oba zamaha pogode.

Kada igrač primi štetu, funkcija take_damage proverava da li je igrač već mrtav ili nepovrediv (is_invincible), i ako nije, oduzima zdravlje, obaveštava HUD o novoj vrednosti i, ako zdravlje padne na nulu ili ispod, poziva die(). U suprotnom, pokreće se play_damage_animation(), koja postavlja is_invincible na true, pušta animaciju "damage" i čeka njen kraj pre nego što ponovo dozvoli primanje štete. Ovo znači da trajanje nepovredivosti nije fiksno vreme u sekundama, već je vezano za dužinu animacije primanja udarca.

Pored ovog sistema, u kodu postoji i drugi, potpuno odvojen mehanizam nepovredivosti koji se odnosi samo na kontaktnu štetu od neprijatelja iz grupe "contact_damage" (trenutno samo enemymob). Taj mehanizam koristi fiksni tajmer od jedne sekunde (CONTACT_DAMAGE_COOLDOWN) nezavisno od is_invincible fleg-a, tako da igrač posle kontakta sa ovim tipom neprijatelja ne može ponovo da primi kontaktnu štetu narednu sekundu, čak i ako se animacija povrede u međuvremenu završila. Ova dva sistema nepovredivosti postoje paralelno i ne komuniciraju direktno jedan sa drugim.

Neprijatelji, za razliku od igrača, nemaju sopstveni sistem i-frames. Kada neprijatelj primi štetu, jedina vizuelna povratna informacija je kratak tvin efekat trepćuće boje (kod finalnog bosa) ili animacija "hurt" koja blokira animaciju kretanja dok traje (kod bigSkelly-ja), ali funkcija take_damage se ne blokira dodatnim uslovom osim provere da li je neprijatelj već mrtav. To znači da neprijatelj tehnički može primiti više pogodaka u brzom nizu bez ikakvog perioda predaha.

### Napitak za zdravlje

Napitak zdravlja je implementiran u scripts/health_potion.gd kao Area2D čvor. Kada telo sa metodom heal() (odnosno igrač) uđe u zonu napitka, poziva se body.heal(heal_amount), gde je heal_amount podrazumevano 2 poena zdravlja, a zatim se napitak uklanja iz scene (queue_free()). Funkcija heal() u player.gd ograničava zdravlje na maksimalnu vrednost pomoću min(), tako da uzimanje napitka na punom zdravlju ne prelazi maksimum.

Napici imaju blagi vizuelni efekat lebdenja, ostvaren pomeranjem sprajta po sinusnoj funkciji vremena (Time.get_ticks_msec()) u funkciji _physics_process, sa podesivom amplitudom (bob_amount) i brzinom (bob_speed). Isti obrazac lebdenja se koristi i kod predmeta ključa (key_item.gd).

Napici zdravlja se u igri pojavljuju na dva načina: ručno postavljeni kao statični predmeti direktno u sceni nivoa (četiri komada u level_1, sedam komada u level_2), i kao predmet koji ispadne iz izvršioca (executioner) kada bude poražen, kroz funkciju _drop_health_potion() u executioner.gd.

### Ponašanje neprijatelja

Svi neprijatelji u igri (enemymob, demon, executioner, bigSkelly, finalni bos) dele sličan osnovni obrazac ponašanja, iako se razlikuju u detaljima. Svaki neprijatelj pamti svoju početnu poziciju (spawn_position) prilikom pokretanja scene. Neprijatelji koji imaju DetectionArea zonu (svi osim enemymob-a) počinju da jure igrača (chasing = true) kada on uđe u tu zonu, i prestaju da ga jure kada izađe iz nje, nakon čega se vraćaju ka svojoj početnoj poziciji.

enemymob i demon dodatno imaju sistem patroliranja između dve unapred postavljene tačke (Marker2D čvorovi Point1 i Point2), sa kratkom pauzom (wait_time) na svakoj tački pre nego što krenu ka sledećoj. Ovo patroliranje se prekida čim neprijatelj počne da juri igrača, i nastavlja se (od najbliže naredne tačke) kada se igrač udalji.

Svaki neprijatelj koji ima Hurtbox zonu prima štetu preko funkcije _on_hurtbox_entered, koja proverava da li je zona koja je ušla u kontakt igračeva AttackArea, i ako jeste, poziva take_damage(1). Kada zdravlje neprijatelja padne na nulu, poziva se funkcija die(), koja zaustavlja kretanje, pušta animaciju smrti, čeka njen kraj, po potrebi ispušta predmet (napitak zdravlja ili ključ), i na kraju uklanja neprijatelja iz scene pomoću queue_free().

Vredi napomenuti sitan, ali dosledan detalj u kodu: i enemymob i demon koriste naziv animacije "flying" za svoje stanje kretanja u funkciji update_animation, iako je enemymob obična pešačka jedinica bez leta. Ovo je najverovatnije posledica toga što je kod enemymob-a nastao kopiranjem koda od demon-a (leteći neprijatelj), pri čemu naziv animacionog stanja nije prilagođen, iako to ne utiče na samu fiziku kretanja, samo na to koja se sličica animacije prikazuje.

### Borba sa finalnim bosom

Finalni bos je implementiran u scripts/boss.gd i ima 20 poena zdravlja, duplo više od ostalih neprijatelja u igri. Poseduje dva odvojena tipa napada sa nezavisnim tajmerima hlađenja: melee_attack() za borbu izbliza (melee_cooldown = 1.2 sekunde) i cast_spell() za napad na daljinu (cast_cooldown = 3.0 sekunde). Funkcija choose_attack() bira koji će se napad izvesti u zavisnosti od toga da li se igrač trenutno nalazi u zoni napada izbliza (player_in_attack_area).

Napad na daljinu se izvodi tako što bos, posle kratkog kašnjenja (portal_cast_delay = 0.4 sekunde) od početka animacije "cast", instancira Portal scenu (scripts/portal.gd) na poziciji igrača, uvećanoj za vertikalni pomeraj (portal_height_offset = -60). Portal je zapravo hazard sa vizuelnim upozorenjem: prvo se prikazuje kroz animaciju određeno vreme (telegraph_time) pre nego što njegova kolizija postane aktivna, tako da igrač ima vremena da se skloni sa te pozicije pre nego što hazard počne da nanosi štetu.

Kada zdravlje bosa padne na nulu, poziva se die() funkcija, koja pokreće poseban niz događaja različit od ostalih neprijatelja. Prvo se pušta animacija smrti bosa i čeka njen kraj. Zatim se zamrzava igrač, postavljanjem njegovog is_dead fleg-a na true i brzine na nulu, čime se sprečava svako dalje kretanje ili napad, iako scena tehnički nije završena. Posle pauze od 2 sekunde, kreira se novi CanvasLayer sa crnim ColorRect čvorom čija se providnost postepeno povećava tvinom u trajanju od 1 sekunde, ostvarujući zatamnjenje celog ekrana. Tek kada se ekran potpuno zacrni, poziva se get_tree().change_scene_to_file() ka sceni ending.tscn.

Ovaj mehanizam zatamnjenja je namerno napravljen samostalno unutar boss.gd, umesto da koristi postojeći DeathScreen/Fade čvor iz scene nivoa, jer taj čvor ima poznat problem sa providnošću opisan u poglavlju 12 (Buduća unapređenja). Poslednji nivo ne sadrži nijednog drugog neprijatelja osim finalnog bosa, tako da je čitav treći nivo posvećen isključivo ovoj borbi.

### Prelazak između nivoa

Prelazak između nivoa je implementiran generičkom skriptom scripts/door.gd, koja se koristi za vrata u level_1 i level_2. Skripta podržava dva nezavisna uslova za otključavanje, koji se mogu kombinovati ili koristiti pojedinačno: requires_key (igrač mora imati ključ, has_key == true) i requires_guard_defeat (određena grupa neprijatelja, podrazumevano nazvana "executioner", mora biti prazna, odnosno svi njeni članovi moraju biti poraženi).

Vrata prikazuju natpis (Prompt Label) koji se menja u zavisnosti od stanja: "Press E" kada je uslov ispunjen, "Locked - defeat the executioner" ako nedostaje poraz čuvara, ili "Locked - find the key" ako nedostaje ključ. Dok se koristi uslov requires_guard_defeat, natpis se osvežava u svakom frejmu (_process), jer se stanje grupe neprijatelja može promeniti u realnom vremenu dok igrač stoji pored vrata i posmatra borbu. Natpis se pojavljuje i nestaje kroz kratak tvin providnosti kada igrač uđe, odnosno izađe iz zone vrata.

Kada igrač pritisne taster za interakciju dok stoji pored vrata i uslov je ispunjen, pokreće se _transition(): postojeći DeathScreen/Fade čvor iz trenutne scene se čini vidljivim i njegova providnost se tvinuje ka jedinici u trajanju od jedne sekunde, a zatim se učitava sledeća scena (target_scene).

Konkretno, vrata u level_1 imaju requires_guard_defeat = true (sa podrazumevanim ciljem level_2.tscn iz same skripte), i otključavaju se porazom neprijatelja iz grupe "executioner", kojih u prvom nivou ima tačno jedan. Vrata u level_2 imaju requires_key = true i eksplicitno postavljen target_scene = "res://levels/level_3.tscn", a ključ potreban za njihovo otključavanje ispada iz poraženog mini-bosa bigSkelly. Treći nivo nema vrata; on se završava isključivo porazom finalnog bosa, opisanim u prethodnom odeljku.

### Smrt igrača i restart nivoa

Kada zdravlje igrača padne na nulu, poziva se die() u player.gd. Igrač se zamrzava (is_dead = true, brzina nula), pušta se animacija smrti i čeka njen kraj. Zatim skripta pronalazi DeathScreen čvor u trenutnoj sceni (get_tree().current_scene.get_node("DeathScreen")) i unutar njega Fade i YouDied čvorove, čini DeathScreen vidljivim, tvinuje providnost Fade čvora ka jedinici u trajanju od 1.5 sekunde, a zatim tvinuje providnost natpisa "YOU DIED" ka jedinici u trajanju od 1 sekunde. Posle dodatne pauze od 2 sekunde, poziva se get_tree().reload_current_scene(), čime se ceo nivo učitava iznova, potpuno od početka.

Ovo znači da igra trenutno nema nikakav sistem čekpointa niti delimičnog čuvanja napretka unutar nivoa: svi poraženi neprijatelji, pokupljeni napici i ključevi, i pozicija igrača se gube i nivo počinje ispočetka, isto kao da je pokrenut prvi put. Isti mehanizam smrti se koristi i kada igrač uđe u KillZone (na primer padom van granica nivoa), jer KillZone skripta jednostavno poziva body.die() direktno.

Vredi napomenuti da Fade ColorRect čvor unutar DeathScreen-a u sve tri scene nivoa ima osnovnu boju sa providnošću 0 (Color(0, 0, 0, 0)), dok skripta menja samo njegov modulate:a. Pošto je konačna providnost čvora u Godot-u proizvod boje i modulate vrednosti, ovo znači da bi zatamnjenje pozadine iza natpisa "YOU DIED" moglo ostati nevidljivo, dok bi sam tekst (koji ima sopstvenu, odvojenu boju) i dalje postao vidljiv. Ovaj problem je detaljnije opisan u poglavlju 12.

## 7. Korisnički interfejs

### Prikaz zdravlja

Zdravlje igrača se prikazuje kroz TextureProgressBar čvor unutar HUD CanvasLayer-a, upravljan skriptom levels/hud.gd. Traka koristi tri odvojene teksture: texture_under i texture_progress obe koriste Health_1.png (pozadinu pune trake i deo koji predstavlja trenutno popunjeno zdravlje), dok texture_over koristi Border_1.png kao dekorativni okvir iscrtan preko trake.

Prilikom pokretanja nivoa, skripta pronalazi igrača u sceni i postavlja maksimalnu vrednost trake na player.max_health (trenutno 10), umesto da se oslanja na vrednost postavljenu direktno u uređivaču scena (koja je u fajlovima nivoa ostala na staroj vrednosti 5, ali se odmah pri pokretanju prepisuje tačnom vrednošću iz koda). Kada se zdravlje promeni, ne prikazuje se odmah nova vrednost, već se u funkciji _process vrednost trake postepeno pomera (lerp) ka ciljnoj vrednosti brzinom srazmernom deltavremenu, što stvara blag animirani prelaz umesto naglog skoka.

U projektu postoji i drugi, sličan fajl, levels/health_bar.gd, koji sadrži jednostavniju verziju iste ideje sa fiksnom maksimalnom vrednošću 15, ali koji nije povezan ni sa jednim čvorom ni u jednoj sceni nivoa. Ovaj fajl predstavlja mrtav kod, odnosno raniju verziju HUD logike koja je zamenjena trenutnom, dinamičkom verzijom, ali nikada nije uklonjena iz projekta.

### Glavni meni

Glavni meni je implementiran u main_menu.tscn i main_menu.gd. Sastoji se od pozadinske slike (backgroundtexture.png), naslova "Gravemourne" ispisanog CinzelDecorative-Regular fontom veličine 42 u boji #c8a96e, i vertikalne liste od četiri dugmeta (New Game, Controls, Options, Quit) stilizovane Cinzel fontom veličine 20, u istoj boji, sa belom bojom prilikom prelaska mišem preko dugmeta (font_hover_color).

Zanimljivo je da se skoro sve pozicioniranje i veličine elemenata u glavnom meniju ne definišu fiksno u uređivaču scena, već se izračunavaju dinamički u kodu, u funkciji _ready(), na osnovu trenutne veličine viewporta (get_viewport_rect().size). Ovo uključuje poziciju naslova, liste dugmadi, teksta priče i dugmadi za povratak (Back) u pod-ekranima. Glavni meni ne prelazi u novu scenu prilikom otvaranja podekrana (priča, kontrole, opcije), već koristi zasebne ColorRect čvorove (StoryScreen, OptionsMenu, ControlsMenu, FadeOverlay) koji se preklapaju preko istog ekrana i pojavljuju/nestaju kroz tvin animacije providnosti, dok se njihova vidljivost (visible) menja na početku i kraju animacije kako bi bili neaktivni kada nisu na ekranu.

### Ekran sa kontrolama

Ekran sa kontrolama se otvara pritiskom na dugme Controls i prikazuje fiksni tekstualni blok (ControlsList Label) sa sledećim sadržajem, definisanim direktno kao string u main_menu.gd:

```
MOVE        A / D   or   ← →
JUMP        SPACE
ATTACK    K   or   LEFT CLICK
```

Ekran se zatvara dugmetom Back, koje vraća igrača na glavni meni kroz tvin providnosti u trajanju od 0.3 sekunde. Kao što je već pomenuto u poglavlju 5, ovaj tekst ne uključuje taster E za interakciju sa vratima, iako ta kontrola postoji i koristi se u samoj igri. Ovo je nedostatak u sadržaju ekrana, a ne u samoj funkcionalnosti kontrole.

### Ekran sa opcijama

Ekran sa opcijama sadrži dva klizača (HSlider): jedan za jačinu muzike i jedan za jačinu zvučnih efekata, oba sa opsegom od 0 do 1, korakom od 0.01 i početnom vrednošću 1.0. Klizač za muziku je funkcionalno povezan sa AudioServer-om: njegova promena vrednosti (signal value_changed) poziva _on_music_changed, koja menja jačinu Master audio busa u decibelima, koristeći linear_to_db za konverziju linearne vrednosti klizača.

Klizač za zvučne efekte, međutim, trenutno nema stvarnu funkciju: njegov callback _on_sfx_changed postoji, ali mu telo sadrži samo naredbu pass, što znači da promena ovog klizača ne utiče ni na jedan zvuk u igri. Ovo je nedovršena funkcionalnost, detaljnije pomenuta u poglavlju 12.

### Ekran smrti

Ekran smrti (DeathScreen) je zaseban CanvasLayer čvor definisan posebno u svakoj od tri scene nivoa (a ne kao deljena instanca), sa istom unutrašnjom strukturom: Fade ColorRect za zatamnjenje pozadine i Label sa tekstom "YOU DIED" za natpis. Ponašanje ovog ekrana, uključujući i uočeni problem sa providnošću Fade čvora, opisano je u poglavlju 6, u odeljku o smrti igrača.

### Uvodni tekst priče

Uvodni tekst priče se prikazuje posle izbora opcije New Game u glavnom meniju, kroz StoryScreen ColorRect čvor koji prekriva ceo ekran i StoryText Label unutar njega. Tačan tekst, definisan kao konstanta STORY_TEXT u main_menu.gd, glasi:

"Once a thriving town, Gravemourne fell silent when darkness crept from beneath the earth. The dead rose. The living fled. Only ruins and rot remain.

You are a hunter, drawn here by whispers of something ancient, something wrong. No map, no allies. Just your blade and the will to see this through.

Find the source. End it.

Or join the graves."

Tekst je ispisan Almendra-Regular fontom veličine 16, u boji #c8a96e, centriran i sa uključenim automatskim prelamanjem reda (autowrap). Kada se tekst u potpunosti prikaže, na njega se dodaje linija "[Press any key to continue]", a igra zatim čeka bilo kakav unos sa tastature ili miša (waiting_for_key fleg, proveren u _unhandled_input) pre nego što pozove _start_game(), koja kreira sačuvani podatak preko GameManager-a i, posle zatamnjenja ekrana u trajanju od 1.5 sekunde, učitava level_1.tscn.

## 8. Objekti u igri

### Igrač

Igrač je definisan u MC/player.tscn i MC/player.gd kao CharacterBody2D čvor na koliziionom sloju "player" (collision_layer = 2). Koristi sprajt animacije iz seta "Crow Animations" (idle, run, jump, attack, damage, death). Telo koristi CapsuleShape2D obrazac kolizije (radijus 8, visina 36), dok napad koristi zasebnu AttackArea (Area2D) sa pravougaonom kolizijom čija veličina nije posebno definisana u sceni, pa koristi Godot-ovu podrazumevanu vrednost.

Osnovne statistike igrača: maksimalno zdravlje 10, brzina kretanja 200, brzina skoka -400, maksimalno dva uzastopna skoka. Igrač takođe nosi promenljivu has_key, koja beleži da li trenutno poseduje ključ potreban za otvaranje vrata u level_2, i koja se postavlja na true kroz metodu collect_key() kada pokupi predmet ključa.

### enemymob

enemymob (enemiesss/enemymob.tscn, enemiesss/enemymob.gd) je najjednostavniji tip neprijatelja u igri, koji koristi grafiku iz fascikle enemiesss/skelly (skeletonMove i skeletonIdle sličice, 64x64 piksela). Ovaj neprijatelj nema ni zonu detekcije igrača ni poseban napad na blizinu ili daljinu. Umesto toga, patrolira između dve unapred postavljene tačke i nanosi štetu isključivo kontaktom: pripada grupi "contact_damage", koju player.gd proverava u svojoj funkciji _check_enemy_contact, pozivajući take_damage(1) kad god se telo igrača sudari sa telom ovog neprijatelja, sa fiksnim tajmerom hlađenja od jedne sekunde.

enemymob ima 3 poena zdravlja i brzinu kretanja 80, i pojavljuje se u više primeraka i u level_1 i u level_2.

### executioner

executioner (assets/executioner.tscn, čija se skripta nalazi na assets/Undead executioner puppet/executioner.gd) predstavlja jačeg protivnika koji juri i aktivno napada igrača. Ima 10 poena zdravlja i prepoznatljiv napad sastavljen od dva zamaha mačem u istoj animaciji: prvi pogodak se proverava 0.3 sekunde posle početka animacije, a drugi 0.35 sekunde posle zvuka drugog zamaha, sa namernim razmakom kako bi drugi udarac stigao posle isteka igračevog prozora nepovredivosti od prvog udarca. Posle celog napada sledi tajmer hlađenja od jedne sekunde.

Kada bude poražen, executioner ispušta napitak zdravlja (_drop_health_potion) i uklanja se iz grupe "executioner", što je upravo grupa koju vrata u level_1 proveravaju da bi se otključala. Vredi napomenuti da scena executioner.tscn sadrži i pod-stablo čvorova StateMachine, sa decom Idle, Chase i Attack, povezano sa generičkim skriptama scripts/node_finitestate_machine.gd, scripts/node_state.gd i assets/idle_state.gd. Ovi čvorovi predstavljaju napušten pokušaj da se ponašanje neprijatelja organizuje kroz formalnu mašinu stanja, ali executioner.gd ih nikada ne poziva niti referencira; sva stvarna logika ponašanja je napisana direktno kroz promenljive i uslovne grane unutar _physics_process, van tog sistema.

### demon

demon (demon.tscn, demon.gd, verovatno iz asset paketa "Flying Demon 2D Pixel Art") je leteći neprijatelj koji napada na daljinu. Ima 3 poena zdravlja i patrolira između dve tačke kao i enemymob, ali dodatno prati igrača kroz DetectionArea zonu. Umesto fizičke zone napada, demon nakon 0.3 sekunde od početka animacije "attack" instancira Projectile scenu, usmerenu ka poziciji igrača u trenutku napada, sa tajmerom hlađenja od podrazumevano 2 sekunde (attack_cooldown) između napada.

### bigSkelly

bigSkelly (bigSkelly.tscn, scripts/big_skelly.gd, iz asset paketa Skeletons_Free_Pack, varijanta Skeleton_Sword / Skeleton_White) je mini-bos smešten u level_2, sa 10 poena zdravlja. Posle nedavnog balansiranja, bigSkelly ima brzinu kretanja 110 i tajmer hlađenja napada od 0.6 sekundi. Pored osnovnog napada, poseduje tri dodatna mehanizma koji ga čine manje predvidljivim od ostalih neprijatelja:

- nasrtaj (lunge): kada je igrač na srednjoj udaljenosti (do 160 piksela) i van dometa napada, postoji 40% šanse po prilazu da bigSkelly naglo ubrza na 2.5 puta svoju normalnu brzinu na kratko vreme (0.3 sekunde), kako bi brzo skratio razdaljinu;
- dupli udarac: posle uspešnog pogotka postoji 30% šanse da bigSkelly odmah, posle kratke pauze od 0.15 sekundi, ponovi napad umesto da čeka pun tajmer hlađenja;
- pojačano stanje (enrage): kada zdravlje bigSkelly-ja padne na 50% maksimuma, trajno se povećava njegova brzina (1.3 puta), smanjuje tajmer hlađenja napada (na 65% prethodne vrednosti) i povećava šansa za nasrtaj (1.5 puta), praćeno kratkim crvenim bleskom sprajta kao vizuelnim signalom te promene.

Kada bude poražen, bigSkelly ispušta predmet ključa (key_item.tscn), koji je neophodan za otključavanje vrata ka level_3.

### Finalni bos

Finalni bos (finalBoss.tscn, scripts/boss.gd, iz asset paketa Bringer-Of-Death) je najjači neprijatelj u igri, sa 20 poena zdravlja i dva odvojena tipa napada, melee i napad na daljinu preko prizivanja Portal hazarda. Detaljno ponašanje finalnog bosa, uključujući i njegov poseban sled događaja prilikom smrti koji vodi ka završnom ekranu igre, opisano je u poglavlju 6.

### Projektil

Projektil (scripts/projectile.gd, scenes/projectile.tscn) je Area2D čvor koji predstavlja jednostavan projektil na daljinu, korišćen isključivo od strane demon neprijatelja. Kreće se konstantnom brzinom (150) u zadatom pravcu, nanosi 1 poen štete pri kontaktu sa telom koje ima metodu take_damage, i uništava se ili prilikom pogotka ili automatski posle isteka vremena života od 4 sekunde, kako projektili koji promaše ne bi ostali zauvek u sceni.

### Portal

Portal (scripts/portal.gd, scenes/portal.tscn) nije teleportacioni portal u uobičajenom smislu, već hazard koji finalni bos priziva kao svoj napad na daljinu, koristeći animiranu vizuelnu efekat prizivanja iz asset paketa Bringer-Of-Death. Portal prvo prikazuje animaciju upozorenja (telegraph_time = 0.8 sekundi) tokom koje njegova kolizija ostaje isključena, a zatim postaje aktivan hazard koji nanosi 1 poen štete tokom kratkog perioda (active_time = 0.3 sekunde), pre nego što se sam ukloni iz scene.

### Napitak za zdravlje

Napitak zdravlja (scripts/health_potion.gd, scenes/health_potion.tscn) je detaljno opisan u poglavlju 6. Vraća 2 poena zdravlja igraču i koristi se i kao statični predmet postavljen u nivou i kao predmet koji ispada iz poraženog izvršioca.

### Vrata za prelazak nivoa

Vrata (scripts/door.gd) su generička skripta koja se koristi za oba prelaza između nivoa u igri (level_1 ka level_2, i level_2 ka level_3), sa različitim uslovima otključavanja u svakom slučaju. Detaljno ponašanje ove skripte opisano je u poglavlju 6.

### KillZone

KillZone (levels/kill_zone.gd) je Area2D čvor postavljen u svakom nivou, čija je jedina funkcija da, kada igrač uđe u nju, direktno pozove igračevu funkciju die(), pokrećući isti niz događaja kao i gubitak svog zdravlja u borbi. Ovaj čvor se tipično koristi za kažnjavanje pada van granica nivoa, na primer u provaliju ili van platformi.

## 9. Tehnička realizacija

### Scene Tree struktura za oba nivoa

Iako je projekat prvobitno opisan kao da ima dva nivoa, u kodu trenutno postoje tri odvojene scene nivoa: levels/level_1.tscn, levels/level_2.tscn i levels/level_3.tscn, povezane jedna sa drugom preko vrata (level_1 ka level_2, level_2 ka level_3) i preko direktnog prelaska pri porazu finalnog bosa (level_3 ka ending.tscn). Sve tri dele sličnu opštu strukturu čvorova na najvišem nivou scene:

- koren tipa Node2D (Level1, Level2 ili Level3);
- pozadinski slojevi, ostvareni kroz instancu ParallaxBackground scene (level_1 i level_2) ili kroz ručno ugnježdene Sprite2D čvorove različitih imena poput Back, Middle, Middle2 (level_3, gde je paralaksa napravljena bez ParallaxBackground čvora, već ručnim slaganjem sprajtova u roditeljsko-detinjim odnosima radi različite brzine pomeranja);
- TileMap čvor sa statičnom geometrijom nivoa (u level_1 dodatno postoji i posebna TileMap za vodu, unutar sopstvenog WaterParallax sloja);
- instanca igrača (Player), sa dodatim zvučnim čvorovima kao decom (opisano u sledećem odeljku);
- instance neprijatelja raspoređene po nivou (u level_1: tri enemymob-a, jedan executioner, dva demon-a; u level_2: tri enemymob-a, dva executioner-a, šest demon-a i jedan bigSkelly; u level_3: samo finalni bos);
- instance napitaka zdravlja postavljene direktno u sceni (četiri u level_1, sedam u level_2, nijedna u level_3);
- DeathScreen (CanvasLayer sa Fade i YouDied čvorovima), KillZone (Area2D), HUD (CanvasLayer sa TextureProgressBar) i Music (AudioStreamPlayer) čvorovi, prisutni u sve tri scene;
- Door (Area2D) čvor, prisutan samo u level_1 i level_2, opisan u poglavlju 6.

Pored ove tri scene koje čine stvarni tok igre, u projektu postoji i levels/testlevels/testlvl_1.tscn, koja deluje kao razvojna, testna scena. Ona nije povezana ni sa jednim vratima niti predstavlja glavnu scenu projekta, pa nije deo toka kroz koji prolazi igrač prilikom normalne partije.

### Struktura scene igrača

player.tscn sadrži koren CharacterBody2D (Player) sa collision_layer postavljenim na vrednost 2 ("player"). Njegova deca su AnimatedSprite2D (sprajt sa svim animacijama igrača), CollisionShape2D sa CapsuleShape2D oblikom za telo, i AttackArea (Area2D) sa sopstvenim CollisionShape2D pravougaonog oblika za detekciju pogodaka.

Zanimljivo je da sama player.tscn scena ne sadrži zvučne čvorove (AttackSound, RunSound, JumpSound, LandSound), iako ih player.gd očekuje kao decu preko @onready promenljivih ($AttackSound, itd). Ovi čvorovi su umesto toga dodati direktno u svakoj sceni nivoa, kao dodatna deca instance Player-a, van same player.tscn definicije. To znači da se izmena ili dodavanje zvučnog čvora trenutno mora raditi ponaosob u svakoj od tri scene nivoa, umesto na jednom centralnom mestu.

### Struktura scene neprijatelja

Neprijatelji sa sposobnošću jurenja i napada (executioner, bigSkelly, finalni bos) dele sličnu strukturu: koren CharacterBody2D, AnimatedSprite2D, CollisionShape2D za telo, DetectionArea (Area2D koja pokreće jurenje igrača), AttackArea (Area2D koja predstavlja zonu napada izbliza) i Hurtbox (Area2D koja prima štetu od igračevog napada), uz AttackSound (i, kod finalnog bosa, dodatni SpellSound za napad na daljinu).

demon ima skraćenu verziju ove strukture: poseduje DetectionArea i Hurtbox, ali nema AttackArea, jer se njegov napad ne izvodi kroz fizičku zonu, već isključivo kroz instanciranje projektila na daljinu. enemymob ima najjednostavniju strukturu od svih: samo Hurtbox i dve tačke patroliranja (PatrolPoints/Point1, PatrolPoints/Point2), bez ikakve zone detekcije ili napada, u skladu sa svojim ponašanjem opisanim u poglavlju 8.

### Sistem kolizionih slojeva i maski

Projekat definiše tri imenovana koliziiona sloja u project.godot: layer_1 = "ground", layer_2 = "player" i layer_3 = "enemy". Igračevo telo eksplicitno koristi collision_layer = 2 ("player"). Međutim, nijedno telo neprijatelja (koren CharacterBody2D čvor kod enemymob, demon, executioner, bigSkelly i finalnog bosa) nema eksplicitno postavljen collision_layer u svojoj sceni, pa svako od njih ostaje na Godot-ovoj podrazumevanoj vrednosti, što odgovara sloju "ground". Sloj "enemy" (čija bit-vrednost je 4) se u praksi ne koristi za sama tela neprijatelja, već isključivo za njihove AttackArea čvorove, koji imaju collision_layer = 4.

DetectionArea čvorovi su podešeni sa collision_layer = 2 i collision_mask = 2, odnosno postavljeni su na sloj "player" i osluškuju taj isti sloj, čime otkrivaju kada igračevo telo uđe u zonu (izuzetak je executioner, čija DetectionArea ima collision_mask = 3, što je kombinacija bitova za "ground" i "player", verovatno bez posebne funkcionalne posledice pošto se u kodu ionako proverava da li je ušlo telo po imenu "Player"). AttackArea čvorovi neprijatelja imaju collision_layer = 4 ("enemy") i collision_mask = 2 ("player"), čime direktno osluškuju igračevo telo i pokreću signal body_entered kada ono fizički uđe u zonu napada.

Hurtbox čvorovi neprijatelja uglavnom imaju collision_mask = 2, dok im collision_layer ostaje na podrazumevanoj vrednosti (sloj "ground"), sa izuzetkom executioner-a čiji Hurtbox koristi collision_mask = 4. Igračeva AttackArea, slično njegovim zvučnim čvorovima, nema eksplicitno postavljen collision_layer niti collision_mask u sceni, pa ostaje na podrazumevanim vrednostima (layer = 1, mask = 1). Ovo se u praksi poklapa sa podrazumevanim slojem na kom se nalaze neprijateljski Hurtbox čvorovi (takođe sloj 1), pa preklapanje ipak radi, ali to znači da se detekcija pogodaka igračevog napada oslanja na Godot-ovu podrazumevanu vrednost sloja, a ne na eksplicitno definisan "enemy" sloj iz project.godot, za razliku od ostatka sistema koji taj sloj koristi eksplicitno za AttackArea čvorove.

### Kako se AttackArea okreće kroz kod umesto da se pozicionira u editoru

Umesto da postoje dva odvojena hitboksa (levi i desni) ili da se ceo Area2D čvor okreće funkcijom flip_h, projekat koristi jednostavniji pristup: pozicija AttackArea čvora po x-osi se svakog fizičkog frejma iznova izračunava u kodu, na osnovu toga u kom pravcu je lik trenutno okrenut. Kod igrača, player.gd čuva originalnu x-poziciju iz uređivača (attack_offset_x) u _ready(), a zatim u svakom pozivu _physics_process postavlja attack_shape.position.x na tu vrednost ili na njenu suprotnu vrednost, u zavisnosti od fleg-a facing_right.

Isti obrazac se ponavlja kod neprijatelja sa AttackArea čvorom (bigSkelly, finalni bos, executioner), gde se attack_area.position.x svakog frejma postavlja na attack_offset ili -attack_offset, u zavisnosti od facing_right fleg-a tog neprijatelja. Ovaj pristup znači da se orijentacija zone napada nikada ne čuva kao trajno stanje u sceni, već se u potpunosti izračunava iznova u svakom frejmu na osnovu trenutnog pravca kretanja lika.

### Kako se instanciraju projektili i portali kao deca nivoa

Kada demon ispaljuje projektil, funkcija spawn_projectile() u demon.gd instancira Projectile scenu, postavlja joj pravac i početnu poziciju, a zatim je dodaje u scenu pozivom get_parent().add_child(proj). Pošto je demon direktno dete korena nivoa, ovim se projektil dodaje kao dete tog istog korena nivoa, a ne kao dete samog demon-a niti u neki poseban, centralizovani kontejner za projektile.

Isti obrazac koristi i finalni bos: cast_spell() u boss.gd instancira Portal scenu i dodaje je kao dete get_parent()-a, odnosno korena nivoa. U oba slučaja, projekat ne koristi nikakav centralni menadžer aktivnih projektila ili hazarda, niti tehniku ponovnog korišćenja objekata (object pooling). Svaki instancirani projektil ili portal je samostalno odgovoran za sopstveno uništavanje, bilo kroz tajmer isteka vremena života (kod projektila) ili kroz sopstveni redosled telegraph/active faza i tajmer na kraju (kod portala).

## 10. Audio i vizuelni stil

Vizuelni stil igre je pixel art, sa gotičkim i srednjovekovnim tonom koji se provlači kroz čitav projekat: kamene ruševine, gotički enterijeri, groblja i pećine. Kroz sve ekrane korisničkog interfejsa i natpise u igri dosledno se koristi ista, toplo zlatno-bronzana boja teksta (#c8a96e), što daje vizuelnu celovitost čak i kada su pozadinske slike i asset paketi različitog porekla i stila.

Tipografija u igri koristi četiri različita fonta, svaki sa svojom namenom. UnifrakturMaguntia-Regular je gotički blackletter font, težak za čitanje u manjim veličinama, koji je prvobitno korišćen za natpise na vratima; zbog problema sa čitljivošću, taj natpis je u level_2 zamenjen fontom Almendra-Regular uz dodatu konturu teksta radi bolje čitljivosti na svetlijim pozadinama. Cinzel-VariableFont se koristi za dugmad glavnog menija, CinzelDecorative-Regular za naslov igre, a Almendra-Regular za duže, narativne tekstove (uvodna priča, završni tekst igre).

Pozadine i tajlovi su preuzeti iz više različitih gotičkih i dungeon-orijentisanih asset paketa, prepoznatljivih po nazivima fascikli u projektu: cityBG (za gradski ambijent level_1), Parallax_Backgrounds_Cave (za pećinski ambijent level_2), Cold Corridors Files, the_hollow_reliquary, GothicItems, castleTileset, dungeon_sidescroller-Raou i posebna slika Dark Gothic Castle.png korišćena kao pozadina završnog ekrana igre. Sprajtovi likova takođe potiču iz nekoliko odvojenih paketa: Crow Animations za igrača, Skeletons_Free_Pack za enemymob i bigSkelly, jedan neimenovani "Flying Demon" paket za demon-a, Undead executioner puppet (aseprite fajlovi) za executioner-a i Bringer-Of-Death za finalnog bosa i njegov Portal napad.

[IZVOR ASSETA: puna lista izvora i licenci za sve gore navedene pakete, uključujući fontove ako nisu iz javno dostupne Google Fonts kolekcije]

Zvučni dizajn igre pokriva osnovne akcije igrača (koraci, skok, doskok, zamah mačem) i po jedan zvuk napada za svakog neprijatelja koji ga poseduje, uz poseban zvuk kastovanja (SpellSound) kod finalnog bosa. Muzika u pozadini se pušta u petlji preko AudioStreamPlayer čvora (Music) u svakom nivou. level_1 i level_2 koriste istu numeru, iz fajla assets/hpbar/bgmusic.mp3 [NAZIV PESME].

Muzika u level_3, tokom borbe sa finalnim bosom, učitava se iz fajla levels/Starscourge Radahn.mp3. Ovo je prepoznatljiv naziv numere iz komercijalne igre Elden Ring (muzička tema bosa Starscourge Radahn), i sve ukazuje na to da se trenutno radi o privremenoj (placeholder) numeri korišćenoj tokom razvoja, a ne o originalnoj ili licenciranoj muzici. Pre bilo kakvog javnog objavljivanja projekta, ovu numeru je neophodno zameniti originalnom kompozicijom ili numerom sa odgovarajućom licencom, jer njeno zadržavanje predstavlja kršenje autorskih prava.

## 11. Organizacija projekta

Projekat je organizovan u nekoliko tematskih fascikli na nivou korena. Fascikla MC/ sadrži scenu i skriptu igrača (player.tscn, player.gd). Fascikla levels/ sadrži sve tri scene nivoa (level_1.tscn, level_2.tscn, level_3.tscn), pomoćne skripte vezane za nivo (hud.gd, health_bar.gd, kill_zone.gd, collision_shape_2d.gd), deljeni tajlset (shared_tileset.tres), muzičku numeru za treći nivo, i podfasciklu testlevels/ sa jednom testnom scenom koja nije deo glavnog toka igre.

Fascikla scripts/ sadrži većinu gameplay skripti koje nisu direktno vezane za jedan konkretan objekat u korenu projekta: projectile.gd, portal.gd, health_potion.gd, key_item.gd, door.gd, boss.gd, big_skelly.gd, ending.gd, game_manager.gd, kao i dva stub fajla iz napuštenog sistema mašine stanja (node_finitestate_machine.gd, node_state.gd).

Fascikla enemiesss/ sadrži scenu i skriptu za enemymob, zajedno sa dva odvojena sprajt seta (skelly/ za enemymob i Skeletons_Free_Pack/ za bigSkelly, čija se scena bigSkelly.tscn nalazi direktno u korenu projekta) i pojedinačne sličice ATTACK.png / DEATH.png / FLYING.png / IDLE.png korišćene od strane demon.tscn. Fascikla assets/ je najveća i sadrži fontove (assets/fonts/ i pojedinačni UnifrakturMaguntia-Regular.ttf), sve pozadinske i tajl pakete, sprajt pakete za igrača i neprijatelje, i posebnu podfasciklu Undead executioner puppet/ koja, neuobičajeno, sadrži i samu skriptu executioner.gd zajedno sa svojim izvornim aseprite fajlovima.

Fascikla scenes/ sadrži manje, samostalne scene predmeta i efekata: portal.tscn, health_potion.tscn, key_item.tscn, projectile.tscn i ending.tscn (scena završnog ekrana igre), zajedno sa svojim pratećim sličicama. Fascikla bggg/ sadrži pozadinu za groblje korišćenu kroz ParallaxBackground scenu. Na nivou korena projekta nalaze se i main_menu.tscn / main_menu.gd, demon.tscn / demon.gd, finalBoss.tscn, bigSkelly.tscn, city_background.tscn i ikonica projekta.

Fascikla addons/godot_ai/ sadrži razvojni alat, MCP (Model Context Protocol) plugin koji omogućava AI-potpomognuto uređivanje projekta direktno kroz Godot editor. Ovaj alat je registrovan kao editor plugin i autoload u project.godot, ali nije deo same igre koju igrač igra, već isključivo deo razvojnog okruženja.

## 12. Buduća unapređenja

Na osnovu pregleda postojećeg koda, izdvaja se nekoliko konkretnih tačaka koje bi trebalo rešiti pre nego što bi se projekat mogao smatrati završenim ili spremnim za objavljivanje:

- Zameniti privremenu muziku bosa. Numera Starscourge Radahn.mp3, korišćena u level_3, potiče iz komercijalne igre Elden Ring i mora biti zamenjena originalnom ili propisno licenciranom kompozicijom.
- Proveriti i po potrebi ispraviti providnost DeathScreen/Fade čvora. Osnovna boja tog čvora ima providnost 0 u sve tri scene nivoa, dok kod tvinuje samo modulate:a vrednost, što po pravilima kompozicije providnosti u Godot-u može značiti da se pozadina iza natpisa "YOU DIED" u praksi ne zatamnjuje kako je verovatno bila namera.
- Dovršiti klizač za jačinu zvučnih efekata u ekranu opcija, čiji callback trenutno ne radi ništa.
- Dodati taster E (interakcija) na ekran sa kontrolama u glavnom meniju, koji ga trenutno ne pominje iako je ta kontrola aktivna u igri.
- Ukloniti ili stvarno iskoristiti mrtav kod: assets/gravity.gd i assets/state_machine.gd (prazni, nekorišćeni fajlovi), levels/health_bar.gd (zamenjena verzija HUD logike), i napušteno StateMachine/Idle/Chase/Attack pod-stablo čvorova u executioner.tscn koje se ne koristi u stvarnom ponašanju tog neprijatelja.
- Razmisliti o sistemu čuvanja napretka unutar nivoa. Trenutni GameManager čuva samo putanju do poslednjeg nivoa u trenutku početka nove igre, dok smrt igrača uvek vraća ceo nivo na početak, bez ikakvih međukoraka (checkpoint sistema).
- Ujednačiti collision_layer vrednosti neprijateljskih tela sa deklarisanim slojem "enemy" iz project.godot, umesto oslanjanja na podrazumevani sloj "ground", radi jasnije i doslednije organizacije fizike u projektu.
- Razmisliti o pauza meniju, koji trenutno ne postoji ni u jednoj sceni niti skripti projekta.
- Proširiti broj nivoa i raznovrsnost neprijatelja, ako se projekat dalje razvija u tom pravcu, kao i razmotriti podršku za kontroler (gamepad), koja trenutno nije definisana u Input Map-u.
- Playtestirati nedavno izmenjeno ponašanje bigSkelly-ja (nasrtaj, dupli udarac, pojačano stanje na 50% zdravlja), kako bi se potvrdilo da je nova težina borbe balansirana, a ne prenaporna.

## 13. Zaključak

Gravemourne je u svom trenutnom obliku funkcionalna, igriva 2D akciona igra sa jasno definisanim tokom kroz tri nivoa, raznovrsnim skupom neprijatelja različite složenosti ponašanja i jednim finalnim bosom koji zaokružuje iskustvo posebnim, scenski uređenim krajem. Osnovne mehanike, kretanje, borba, zdravlje i nepovredivost, otključavanje vrata i smrt/restart nivoa, sve su implementirane i međusobno povezane na dosledan način, iako ne uvek na najelegantniji mogući način sa tehničke strane.

Najveća snaga projekta leži u doslednosti vizuelnog i audio identiteta (boja teksta, izbor fontova, gotička tema) i u tome što je borbeni sistem, uprkos relativnoj jednostavnosti, dovoljno razrađen da svaki tip neprijatelja pruža drugačije iskustvo, od jednostavnog kontaktnog enemymob-a, preko dvostrukog udarca izvršioca, do nedavno dodate nepredvidljivosti bigSkelly-ja i dvostrukog repertoara napada finalnog bosa.

Najveće slabosti su, kao što je detaljno opisano u poglavlju 12, nekoliko ostataka ranijih verzija koda koji nisu do kraja očišćeni ili povezani (napuštena mašina stanja, nekorišćene skripte, HUD skripta koja se ne koristi), nedovršena funkcionalnost u ekranu opcija, i odsustvo sistema čuvanja napretka unutar nivoa. Nijedna od ovih stavki ne sprečava igru da bude igriva od početka do kraja, ali njihovo rešavanje bi znatno poboljšalo i utisak igrača i preglednost samog koda za dalji razvoj.

Ovaj dokument je pokušaj da se to trenutno stanje vidljivo i pošteno opiše, kao osnova i za akademsku predaju projekta i za bilo kakav dalji rad na igri.

## 14. Literatura

- Godot Engine Documentation, zvanična dokumentacija Godot Engine 4.6, https://docs.godotengine.org
- GDScript Reference, deo zvanične Godot dokumentacije koji opisuje sintaksu i konvencije GDScript jezika korišćenog u čitavom projektu
- Izvorni kod projekta Gravemourne (sve .tscn i .gd datoteke unutar projekta), kao primarni izvor svih činjenica navedenih u ovom dokumentu
- [IZVOR ASSETA]: spisak korišćenih grafičkih, font i audio paketa treće strane, sa tačnim izvorima i licencama, naveden u poglavlju 10
