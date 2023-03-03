bool is_block(int x, int y) const {
    return false;
}

// sv: sight vector. stores the farest pos in sight
bool check_los(int x1, int y1, int x2, int y2, Vector2 *sv) const {
    // first point
    if (sv) {
        sv->set(x1, y1);
    }

    if (is_block(x1, y1))
        return false;

    int x = x1,       y = y1;
    int dx = x2 - x1, dy = y2 - y1;

    int xstep, ystep;
    int ddx, ddy;
    int err;

    if (dx < 0) {
        xstep = -1;
        dx = -dx;
    } else {
        xstep = 1;
    }

    if (dy < 0) {
        ystep = -1;
        dy = -dy;
    } else {
        ystep = 1;
    }

    ddx = dx << 1;
    ddy = dy << 1;

    if (ddy >= ddx) {
        err = dy;
        for (int i = 0; i < dy; i++) {
            y += ystep;
            err += ddx;
            if (err > ddy) {
                x += xstep;
                err -= ddy;
            }

            if (is_block(x, y))
                return false;
            else if (sv)
                sv->set(x, y);
        }
    } else {
        err = dx;
        for (int i = 0; i < dx; i++) {
            x += xstep;
            err += ddy;
            if (err > ddx) {
                y += ystep;
                err -= ddx;
            }

            if (is_block(x, y))
                return false;
            else if (sv)
                sv->set(x, y);
        }
    }

    // last point
    if (sv)
        sv->set(x2, y2);

    return true;
}
