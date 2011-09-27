# Temporary monkey patching to get Sunspot to use the new edismax query type.
    
OriginalDismax = Sunspot::Query::Dismax

class PatchedDismax < OriginalDismax
  
  def to_params
    params = super
    params[:defType] = 'edismax'
    params
  end
  
  def to_subquery
    query = super
    query = query.sub '{!dismax', '{!edismax'
    query
  end
  
end

Sunspot::Query.send :remove_const, :Dismax
Sunspot::Query::Dismax = PatchedDismax