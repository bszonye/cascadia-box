echo("\n\n====== CASCADIA ORGANIZER ======\n\n");

include <game-box/game.scad>

Qprint = Qfinal;  // or Qdraft

// box metrics
Vgame = [232, 232, 68];  // box interior
Hwrap = 48;  // cover art wrap ends here, approximately
Hmanual = 3.0;
Hceiling = floor(Vgame.z - Hmanual);

// card metrics
// TODO: put card measurements in library
Vcard = Vsleeve_orange;  // Gamegenic Tarot
Hcard = 0.320 + Hsleeve_prime;  // measured ca. 520 microns with sleeves
Vlcard = Vsleeve_yellow;  // Gamegenic Mini American
Hlcard = 0.320 + Hsleeve_prime;  // TBD
Vcard_divider = [75, 125];

// container metrics
// TODO: leave room for score pads?
Htray = Hceiling / 2;
Vtray = [80, 130, Htray];  // wildlife cards
Vltray = [75, 47, 50];  // landmark cards

module slotted_tray(size=Vtray, height=undef, slots=5, notch=false,
                    color=undef) {
    // tray with multiple slots and optional notch
    v = volume(size, height);
    cell = [v.x - 2*Dwall, (v.y - Dwall) / slots - Dwall];
    echo(slots=slots, cell=cell);
    colorize(color) difference() {
        prism(v, r=Rext);
        raise(Hfloor) for (j=[1/2:slots]) {
            translate([0, v.y/2 - Dwall/2 - j*(cell.y+Dwall)])
                prism(cell, r=Rint);
        }
        if (notch) {
            // side cuts
            hvee = v.z/2;
            zvee = v.z-hvee;
            xvee = tround(zvee/sin(Avee));
            dtop = 2*xvee;
            vend = [xvee, v.y, zvee];
            echo(vbox=v, dtop=dtop, zvee=zvee, xvee=xvee);
            raise(hvee) wall_vee_cut(vend);  // end vee
        }
    }
    raise(v.z + Dgap) children();
}

module wildlife_card_tray(height=Htray, color=undef) {
    card_tray(height=height, color=color) children();
}
module landmark_card_tray(color=undef) {
    slotted_tray(size=Vltray, notch=true, color=color) children();
}
module landmark_token_tray(height=Htray, color=undef) {
    slotted_tray(height=height, color=color) children();
}

module organizer() {
    %box_frame();
    translate([Vgame.x - Vtray.x, Vtray.y - Vgame.y] / 2) {
        landmark_token_tray(color="#004000")
        wildlife_card_tray(color="#004000")
            deck(2)
            tray_divider(color="#ff8000")  // fox
            deck(8)
            tray_divider(color="#80c0ff")  // hawk
            deck(8)
            tray_divider(color="#ff0080")  // salmon
            deck(8)
            tray_divider(color="#e0c080")  // elk
            deck(8)
            tray_divider(color="#804000")  // bear
            deck(8)
            tray_divider(color="#004000")  // cover
            ;
    }
    translate([Vgame.x - Vltray.y, Vgame.y - Vltray.x] / 2)
        rotate(90) landmark_card_tray(color="#004000");
}

organizer();
*test_game_shapes($fa=Qdraft);

*tray_foot($fa=Qprint);
*wildlife_card_tray($fa=Qprint);
*landmark_card_tray($fa=Qprint);
*landmark_token_tray($fa=Qprint);
*tray_divider($fa=Qprint);
