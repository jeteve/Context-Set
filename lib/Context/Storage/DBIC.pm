package Context::Storage::DBIC;
use Moose;
extends qw/Context::Storage/;

=head1 NAME

Context::Storage::DBIC - Manage context persistence in a L<DBIx::Class::ResultSet>

=cut

has 'resultset' => ( is => 'ro', isa => 'DBIx::Class::ResultSet' , required => 1 );

sub populate_context{
  my ($self,$context) = @_;

  my $kvs = $self->resultset->search_rs({ context_name => $context->fullname() },
                                        { order_by => [ 'key' , 'id' ] }
                                       );
  my $properties = {};
  while( my $kv = $kvs->next() ){
    my ($k ,$v) = ( $kv->key() , $kv->value() );
    $properties->{$k} //= [];
    if( $kv->is_array() ){
      push @{$properties->{$k}} , $v;
    }else{
      $properties->{$k} = $v;
    }
  }

  ## Inject all of that in the context.
  $context->properties($properties);
}

sub set_context_property{
  my ($self, $context, $prop , $v , $after ) = @_;

  my $stuff = sub{
    my $is_array = 1;
    ## Normalize v
    unless( ref($v // 'nothing') eq 'ARRAY' ){
      $v = [ $v ];
      $is_array = 0;
    }

    my $fullname = $context->fullname();

    ## Blat the key
    $self->resultset()->search_rs({ context_name => $fullname,
                                    key => $prop
                                  })->delete();

    foreach my $value ( @$v ){
      $self->resultset()->create({ context_name => $fullname,
                                   key => $prop,
                                   value => $value,
                                   is_array => $is_array
                                 });
    }
    return &{$after}();
  };
  return $self->resultset->result_source->schema()->txn_do($stuff);
}


__PACKAGE__->meta->make_immutable();
1;
