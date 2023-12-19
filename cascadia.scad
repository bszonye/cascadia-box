echo("\n\n====== CASCADIA ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

// Cascadia sets come in fives
Nwild = 5;

// box metrics
Vgame = [232, 232, 68];  // box interior
Hwrap = 48;  // cover art wrap ends here, approximately
Hmanual = 3.0;
Hceiling = floor(Vgame.z - Hmanual);

// card metrics
// wildlife scoring cards w/Gamegenic Tarot sleeves
// - 0.510 measured = 0.310 unsleeved (base game)
// - 0.525          = 0.325           (promos)
// - 0.580          = 0.380           (expansion)
// - 0.540          = 0.340           (average)
Hcard_unsleeved = 0.34;
Hcard_sleeve = Hsleeve_prime;
Vcard = Vsleeve_orange;
Vcard_divider = [75, 125];

// landmark scoring cards w/Sleeve Kings Mini European sleeves
// - 0.510 measured = 0.380 unsleeved (expansion)
Hlcard_unsleeved = 0.38;
Hlcard_sleeve = Hsleeve_kings;
Hlcard = Hlcard_unsleeved + Hlcard_sleeve;
Vlcard = Vsleeve_mini_euro;

// container metrics
Hfoot = 0;
Htray = Hceiling / 2;
// wildlife cards & landmark tokens
Vtray = [80, 130, Htray];
// landmark cards
Vbox = [80, 50, 50];
echo(Vbox=Vbox);

// colors
Cgame = "#603000";  // brown
// wildlife
Cbear = "#402000";  // dark brown
Celk = "#e0c080";  // tan
Csalmon = "#ff0080";  // pink
Chawk = "#80c0ff";  // azure
Cfox = "#ff8000";  // orange
// habitats
Cmountain = "#808080";  // gray
Cforest = "#008000";  // dark green
Cprairie = "#e0c040";  // yellow
Cwetland = "#80c000";  // green
Criver = "#0080ff";  // blue

module multi_deck_box(size=Vbox, slots=Nwild, div=3/4*Dwall, color=undef) {
    // tray with multiple slots and optional notch
    v = volume(size);
    cell = [v.x - 2*Dwall, (v.y - 2*Dwall - (slots-1)*div) / slots];
    echo(slots=slots, cell=cell);
    colorize(color) difference() {
        prism(v, r=Rext);
        raise(Hfloor) for (j=[1/2:slots]) {
            translate([0, j*(cell.y+div) - v.y/2 + Dwall - div/2])
                prism(cell, r=Rint);
        }
        // side cuts
        hvee = v.z/2;
        zvee = v.z-hvee;
        xvee = tround(zvee/sin(Avee));
        dtop = 2*xvee;
        vend = [xvee, v.y, zvee];
        echo(vbox=v, dtop=dtop, zvee=zvee, xvee=xvee);
        raise(hvee) wall_vee_cut(vend);  // end vee
    }
    raise(v.z + Dgap) children();
}

module wildlife_card_tray(color=undef) {
    card_tray(height=eceil(Htray, 5), color=color) children();
}
module landmark_deck_box(color=undef) {
    multi_deck_box(color=color) children();
}

module organizer() {
    %box_frame();
    translate([Vgame.x - Vtray.x, Vtray.y - Vgame.y] / 2) {
        wildlife_card_tray(color=Cgame)
            deck(2)
            tray_divider(color=Cfox)  // fox
            deck(8)
            tray_divider(color=Chawk)  // hawk
            deck(8)
            tray_divider(color=Csalmon)  // salmon
            deck(8)
            tray_divider(color=Celk)  // elk
            deck(8)
            tray_divider(color=Cbear)  // bear
            deck(8)
            tray_divider(color=Cgame)  // cover
            ;
    }
    translate([Vgame.x - Vbox.y, Vgame.y - Vbox.x] / 2)
        rotate(90) landmark_deck_box(color=Cgame);
}

*organizer();
*test_game_shapes($fa=Qdraft);

*wildlife_card_tray($fa=Qprint);
landmark_deck_box($fa=Qprint);
*tray_divider($fa=Qprint);
