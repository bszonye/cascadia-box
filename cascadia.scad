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

// component metrics
Hpad = 7;
Vpad1 = [66, 161, Hpad];
Vpad2 = [87.5, 175, Hpad];
Hpad_ceiling = Hceiling - Hpad;
// habitat tiles
Rhex = 24;  // side length / major radius

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
Htray = eceil(Hceiling / 2, 5);
// wildlife card tray
Vtray = [80, 130, Htray];
// landmark deck box
Vbox = [80, 50, 50];
echo(Vbox=Vbox);
// nature token trays
Vnature = [40, 50, efloor(Hceiling/3, Hflayer)];
echo(Vnature=Vnature);
// habitat tile rack & landmark token base
Vtile = [56, 56, 45];
Vbase = [60, 60, 15];
Hnest = Vbase.z + Vtile.z - Hpad_ceiling;
Rnest = Rext + 0.5;  // nest corner radius
Rbase = (Vbase.x - Vtile.x) / 2 + Rext;  // base exterior radius
Dnest = Rbase - Rnest;  // nest wall thickness
Dbase = 2 * Dnest;  // base wall thickness
Rwell = Rbase - Dbase;  // base interior radius
echo(Hnest=Hnest, Rnest=Rnest, Rbase=Rbase, Dnest=Dnest, Dbase=Dbase, Rwell=Rwell);

// colors
Cgame = "#603000";  // brown
// wildlife
Cbear = "#402000";  // dark brown
Celk = "#e0c080";  // tan
Csalmon = "#ff0080";  // pink
Chawk = "#80c0ff";  // azure
Cfox = "#ff8000";  // orange
// habitats
Csnow = "#c0c0c0";  // light gray
Cmountain = "#808080";  // gray
Cforest = "#004000";  // dark green
Cprairie = "#ffe040";  // yellow
Camber = "#ff8000";  // amber
Cwetland = "#80c000";  // green
Criver = "#0080ff";  // blue
// tile racks
Ctile = [Criver, Cmountain, Cwetland, Cforest, Cprairie, Camber];


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
    card_tray(color=color) children();
}
module landmark_deck_box(color=undef) {
    multi_deck_box(color=color) children();
}

module hex_cut(size, height=undef, cut=Dcut) {
    a0 = 60;
    v = volume(size, height);
    run = a0 < 90 ? 1/tan(a0) : 0;
    a1 = 90 - a0/2;
    y1 = v.z;
    y2 = v.z + cut;
    x0 = v.x/2;
    x1 = x0 + y1*run;
    phex = [[x1, y2], [x1, y1], [x0, 0], [-x0, 0], [-x1, y1], [-x1, y2]];
    d = v.y + 2*cut;
    rotate([90, 0, 0]) prism(height=d, center=true) polygon(phex);
}
module habitat_tile_rack(size=Vtile, color=undef) {
    v = volume(size);
    shell = area(v);
    well = shell - 2 * area(Dwall);
    colorize(color) difference() {
        prism(shell, height=v.z, r=Rext);
        raise(Hfloor) intersection() {
            prism(well, height=v.z, r=Rint);
            hex_cut([floor(Rhex)+Rint, well.x], height=v.z);
        }
        hvee = floor(v.z / 3);
        zvee = v.z - hvee;
        translate([0, -shell.y/2, zvee]) rotate(90)
            wall_vee_cut(shell, height=hvee);
        translate([0, -well.y/2-Dwall/2, zvee/2])
            wall_vee_cut([well.x/3, Dwall], height=zvee/2);
    }
    raise(v.z + Dgap) children();
}
module landmark_token_base(size=Vbase, color=undef) {
    v = volume(size);
    shell = area(v);
    nest = shell - 2 * area(Dnest);
    well = shell - 2 * area(Dbase);
    h = v.z - Hnest - Hfloor;
    scoop = Rwell;
    lip = h - scoop;
    colorize(color) difference() {
        prism(shell, height=v.z, r=Rbase);
        raise(Hfloor+h) prism(nest, height=Hnest+Dcut, r=Rnest);
        raise(Hfloor) scoop_well(well, h, rint=Rwell, rscoop=scoop, lip=lip);
    }
    raise(v.z - Hnest + Dgap) children();
}
module nature_token_tray(size=Vnature, color=undef) {
    v = volume(size);
    shell = area(v);
    well = shell - 2 * area(Dwall);
    h = v.z - Hfloor;
    colorize(color) difference() {
        prism(shell, height=v.z, r=Rext);
        raise(Hfloor) scoop_well(well, h, lip=h-2*Rext);
    }
    raise(v.z + Dgap) children();
}
module start_tile_tray(color=undef) {
    colorize(color) difference() {
    }
}

module organizer() {
    %box_frame();
    translate([Vgame.x/4, Vtray.y/2 - Vgame.y/2]) {
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
        raise(Htray+Dgap) start_tile_tray(color=Cgame);
    }
    translate([Vnature.x/2 - Vgame.x/2, Vgame.y/2 - Vbox.y/2])
        nature_token_tray(color=Cforest)
        nature_token_tray(color=Cforest)
        nature_token_tray(color=Cforest);
    translate([Vbox.x/2 - Vgame.x/2 + Vnature.x + Dgap, Vgame.y/2 - Vbox.y/2])
        landmark_deck_box(color=Cgame);
    for (i=[0:1]) for (j=[0:2]) {
        origin = [Vbase.x - Vgame.x, Vbase.y - Vgame.y] / 2;
        cnum = 2*j + i;
        translate(origin + [i*(Vbase.x+Dgap), j*(Vbase.y+Dgap)])
            landmark_token_base(color=Ctile[cnum])
            raise(5*cnum) habitat_tile_rack(color=Ctile[cnum]);
    }
}

organizer();
*test_game_shapes($fa=Qdraft);

*wildlife_card_tray($fa=Qprint);
*landmark_deck_box($fa=Qprint);
*tray_divider($fa=Qprint);
*landmark_token_base($fa=Qprint);
*habitat_tile_rack($fa=Qprint);
*nature_token_tray($fa=Qprint);
