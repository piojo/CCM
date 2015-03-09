object template escape;

variable TOESCAPE = list(
    "test",
    "whitespaces whitespaces",
    escape("double escape"),
    " ", # only whitespace
);

"/" = {
    foreach(idx;value;TOESCAPE) {
        SELF[escape(value)]=value;
    };
    SELF;
};
